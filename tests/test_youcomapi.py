"""Tests for the You.com search tool (youcomapi) in KaliGPT."""

import json
from types import SimpleNamespace
from unittest import mock

import pytest

import requests

from agents.utils.tools import youcomapi


def _json_response(body, headers=None, status_code=200):
    """Build a fake requests.Response carrying a JSON body."""
    resp = SimpleNamespace(status_code=status_code, headers=dict(headers or {}))
    resp.headers.setdefault("Content-Type", "application/json")
    resp.json = lambda: body
    resp.raise_for_status = lambda: None if status_code < 400 else _raise_for_status(status_code)
    return resp


def _sse_response(payload, notification=None, headers=None, status_code=200):
    """Build a fake requests.Response carrying a text/event-stream body.

    Mirrors the live endpoint, which emits progress notifications before the
    actual JSON-RPC result event.
    """
    resp = SimpleNamespace(status_code=status_code, headers=dict(headers or {}))
    resp.headers["Content-Type"] = "text/event-stream"
    body = ""
    if notification is not None:
        body += f"event: message\ndata: {json.dumps(notification)}\n\n"
    body += f"event: message\ndata: {json.dumps(payload)}\n\n"
    resp.text = body
    resp.raise_for_status = lambda: None if status_code < 400 else _raise_for_status(status_code)
    return resp


def _raise_for_status(status_code):
    raise requests.HTTPError(f"{status_code} error")


def _search_hits(n=2):
    return {"results": {"web": [
        {"title": f"Result {i}", "url": f"https://example.com/{i}", "description": "snippet"}
        for i in range(n)
    ]}}


def _tool_call_payload(hits):
    return {
        "jsonrpc": "2.0",
        "id": 2,
        "result": {"content": [{"type": "text", "text": json.dumps(hits)}]},
    }


class TestEndpointSelection:
    """Verify keyless vs authenticated endpoint resolution."""

    def test_keyless_by_default(self):
        with mock.patch.dict("os.environ", {"YOUCOM_API_KEY": "", "YDC_API_KEY": ""}, clear=False):
            url, headers = youcomapi._get_endpoint_and_headers()
        assert url == youcomapi.YOUCOM_FREE_MCP_URL
        assert "Authorization" not in headers

    def test_ydc_api_key_uses_authenticated_endpoint(self):
        with mock.patch.dict("os.environ", {"YDC_API_KEY": "test-key"}, clear=False):
            url, headers = youcomapi._get_endpoint_and_headers()
        assert url == youcomapi.YOUCOM_MCP_URL
        assert headers["Authorization"] == "Bearer test-key"

    def test_youcom_api_key_uses_authenticated_endpoint(self):
        with mock.patch.dict("os.environ", {"YOUCOM_API_KEY": "test-key-2"}, clear=False):
            url, headers = youcomapi._get_endpoint_and_headers()
        assert url == youcomapi.YOUCOM_MCP_URL
        assert headers["Authorization"] == "Bearer test-key-2"


class TestYoucomSearch:
    """Verify youcom_search handshake, parsing and fail-safe behaviour."""

    def test_parses_results_and_passes_session_id(self):
        init = _json_response({"jsonrpc": "2.0", "id": 1, "result": {"serverInfo": {"name": "You.com"}}},
                              headers={"mcp-session-id": "sess-123"})
        notification = _json_response({}, status_code=202)
        call = _json_response(_tool_call_payload(_search_hits(2)))

        with mock.patch.object(youcomapi.requests, "post", side_effect=[init, notification, call]) as post:
            results = youcomapi.youcom_search("xss cheat sheet", top_n=4)

        assert results == [
            ("Result 0", "https://example.com/0"),
            ("Result 1", "https://example.com/1"),
        ]
        # initialize -> notifications/initialized -> tools/call
        assert post.call_count == 3
        assert post.call_args_list[0].kwargs["json"]["method"] == "initialize"
        assert post.call_args_list[1].kwargs["json"]["method"] == "notifications/initialized"
        assert post.call_args_list[1].kwargs["headers"]["mcp-session-id"] == "sess-123"
        assert post.call_args_list[2].kwargs["json"]["method"] == "tools/call"
        assert post.call_args_list[2].kwargs["json"]["params"]["name"] == "you-search"
        assert post.call_args_list[2].kwargs["headers"]["mcp-session-id"] == "sess-123"

    def test_top_n_caps_results(self):
        init = _json_response({}, headers={"mcp-session-id": "s"})
        notification = _json_response({}, status_code=202)
        call = _json_response(_tool_call_payload(_search_hits(5)))

        with mock.patch.object(youcomapi.requests, "post", side_effect=[init, notification, call]):
            results = youcomapi.youcom_search("query", top_n=2)

        assert len(results) == 2

    def test_handles_sse_response_body(self):
        init = _json_response({}, headers={"mcp-session-id": "s"})
        notification = _json_response({}, status_code=202)
        # live shape: progress notification event first, JSON-RPC result event after
        call = _sse_response(
            _tool_call_payload(_search_hits(1)),
            notification={"jsonrpc": "2.0", "method": "notifications/message",
                          "params": {"level": "info", "data": "Search successful"}},
        )

        with mock.patch.object(youcomapi.requests, "post", side_effect=[init, notification, call]):
            results = youcomapi.youcom_search("query")

        assert results == [("Result 0", "https://example.com/0")]

    def test_sse_without_result_event_fail_safe(self):
        init = _json_response({}, headers={"mcp-session-id": "s"})
        notification = _json_response({}, status_code=202)
        call = _sse_response(
            {"jsonrpc": "2.0", "method": "notifications/message", "params": {"level": "info"}},
        )

        with mock.patch.object(youcomapi.requests, "post", side_effect=[init, notification, call]):
            assert youcomapi.youcom_search("query") == [(None, None)]

    def test_empty_results_fail_safe(self):
        init = _json_response({}, headers={"mcp-session-id": "s"})
        notification = _json_response({}, status_code=202)
        call = _json_response(_tool_call_payload({"results": {"web": []}}))

        with mock.patch.object(youcomapi.requests, "post", side_effect=[init, notification, call]):
            assert youcomapi.youcom_search("query") == [(None, None)]

    def test_http_error_fail_safe(self):
        bad = _json_response({}, status_code=500)

        with mock.patch.object(youcomapi.requests, "post", side_effect=[bad]):
            assert youcomapi.youcom_search("query") == [(None, None)]

    def test_connection_error_fail_safe(self):
        with mock.patch.object(youcomapi.requests, "post",
                               side_effect=requests.ConnectionError("boom")):
            assert youcomapi.youcom_search("query") == [(None, None)]


class TestCheckYoucomConnection:
    """Verify check_youcom_connection mirrors check_search_connection."""

    def test_returns_true_on_200(self):
        ok = _json_response({"jsonrpc": "2.0", "id": 1, "result": {}}, status_code=200)

        with mock.patch.object(youcomapi.requests, "post", side_effect=[ok]) as post:
            assert youcomapi.check_youcom_connection() is True
        assert post.call_args_list[0].kwargs["json"]["method"] == "initialize"

    def test_returns_false_on_exception(self):
        with mock.patch.object(youcomapi.requests, "post",
                               side_effect=requests.Timeout("slow")):
            assert youcomapi.check_youcom_connection() is False


class TestParseResults:
    """Verify the result-shape unwrapping directly."""

    def test_plain_list_shape(self):
        text = json.dumps([{"title": "T", "url": "https://example.com"}])
        assert youcomapi._parse_you_search_results(text, 4) == [("T", "https://example.com")]

    def test_hits_shape(self):
        text = json.dumps({"hits": [{"title": "T", "link": "https://example.com"}]})
        assert youcomapi._parse_you_search_results(text, 4) == [("T", "https://example.com")]

    def test_skips_malformed_items(self):
        text = json.dumps({"results": {"web": [{"title": "no url"}, {"url": "https://a.com"}, "junk", {"title": "T", "url": "https://b.com"}]}})
        assert youcomapi._parse_you_search_results(text, 4) == [("T", "https://b.com")]
