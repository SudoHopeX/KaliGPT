#!/usr/bin/env python3

# /agents/utils/tools/youcomapi.py
# Optional live web search via You.com — works without the local OpenSearchAPI server.
# Keyless by default through the You.com free MCP profile; set YOUCOM_API_KEY or
# YDC_API_KEY to use the authenticated endpoint for fuller results.
# Updated: 1 Oct 2026

import json
import os

import requests

# You.com MCP endpoints (Streamable HTTP JSON-RPC)
YOUCOM_MCP_URL = "https://api.you.com/mcp"
YOUCOM_FREE_MCP_URL = "https://api.you.com/mcp?profile=free"

MCP_PROTOCOL_VERSION = "2025-06-18"
CLIENT_INFO = {"name": "kaligpt", "version": "1.0"}


def _get_endpoint_and_headers():
    """
    Resolves the You.com endpoint & base headers: authenticated when a key is set,
    keyless free profile otherwise.
    """
    api_key = os.environ.get("YOUCOM_API_KEY") or os.environ.get("YDC_API_KEY")
    headers = {
        "Accept": "application/json, text/event-stream",
        "User-Agent": "HackerX YouComSearch/1.0",
    }
    if api_key:
        headers["Authorization"] = f"Bearer {api_key}"
        return YOUCOM_MCP_URL, headers
    return YOUCOM_FREE_MCP_URL, headers


def _extract_json(response):
    """
    Extracts the JSON-RPC result payload from a MCP response (handles both plain
    JSON and text/event-stream bodies, skipping server progress notifications).
    """
    content_type = response.headers.get("Content-Type", "")
    if "text/event-stream" in content_type:
        payload = None
        for line in response.text.splitlines():
            if not line.startswith("data:"):
                continue
            data = line[len("data:"):].strip()
            if not data:
                continue
            try:
                event = json.loads(data)
            except ValueError:
                continue
            # a JSON-RPC response carries a "result" (or "error"); server progress
            # notifications (notifications/message) do not
            if isinstance(event, dict) and ("result" in event or "error" in event):
                payload = event
        if payload is None:
            raise ValueError("no JSON-RPC result event found in SSE response")
        return payload
    return response.json()


def _parse_you_search_results(tool_text, top_n):
    """
    Extracts (title, link) pairs from the you-search tool result text.
    """
    data = json.loads(tool_text)

    # unwrap {"results": {"web": [...]}} / {"hits": [...]} / plain list shapes
    if isinstance(data, dict):
        results = data.get("results")
        if isinstance(results, dict):
            items = results.get("web") or results.get("hits") or []
        elif isinstance(results, list):
            items = results
        else:
            items = data.get("hits") or data.get("web") or []
    else:
        items = data

    search_result = []
    for item in items:
        if not isinstance(item, dict):
            continue

        title = item.get("title")
        link = item.get("url") or item.get("link")

        if not title or not link:
            continue

        search_result.append((title, link))
        if len(search_result) >= top_n:
            break

    return search_result


def check_youcom_connection(timeout: int = 30) -> bool:
    """
    checks if the You.com search backend is reachable (keyless, no local server needed).
    """
    url, headers = _get_endpoint_and_headers()

    # perform an initialize request to test availability
    try:
        response = requests.post(
            url,
            headers=headers,
            timeout=timeout,
            json={
                "jsonrpc": "2.0",
                "id": 1,
                "method": "initialize",
                "params": {
                    "protocolVersion": MCP_PROTOCOL_VERSION,
                    "capabilities": {},
                    "clientInfo": CLIENT_INFO,
                },
            },
        )
        return response.status_code == 200

    except requests.RequestException as re:
        print(f"You.com Search Connection error\nEndpoint used: {url}\nError details: {re}")
        return False    # any exception results as False


def youcom_search(keyword: str, top_n: int = 4, timeout: int = 30) -> list:
    """
    Performs live web search via You.com — an alternative to keyword_search that needs
    no local OpenSearchAPI server (keyless by default; set YOUCOM_API_KEY or YDC_API_KEY
    for authenticated fuller results).

    :param keyword: the keyword/query to search for
    :param top_n: number of results from top to return to llm
    :param timeout: timeout for the requests

    :return: a list of search results in the format of [(title, link), (title, link), ...]
        return [(None, None)] if no search results are found or the backend is unreachable
    """
    url, headers = _get_endpoint_and_headers()

    try:
        # 1. MCP handshake: initialize (the server returns its session id in the headers)
        init_response = requests.post(
            url,
            headers=headers,
            timeout=timeout,
            json={
                "jsonrpc": "2.0",
                "id": 1,
                "method": "initialize",
                "params": {
                    "protocolVersion": MCP_PROTOCOL_VERSION,
                    "capabilities": {},
                    "clientInfo": CLIENT_INFO,
                },
            },
        )
        init_response.raise_for_status()

        session_id = init_response.headers.get("mcp-session-id")
        if session_id:
            headers["mcp-session-id"] = session_id

        # 2. initialized notification (the server replies with an empty 202 body)
        requests.post(
            url,
            headers=headers,
            timeout=timeout,
            json={"jsonrpc": "2.0", "method": "notifications/initialized"},
        )

        # 3. call the you-search tool
        call_response = requests.post(
            url,
            headers=headers,
            timeout=timeout,
            json={
                "jsonrpc": "2.0",
                "id": 2,
                "method": "tools/call",
                "params": {
                    "name": "you-search",
                    "arguments": {"query": keyword, "count": top_n},
                },
            },
        )
        call_response.raise_for_status()

        payload = _extract_json(call_response)
        content = (payload.get("result") or {}).get("content") or []
        tool_text = next(
            (item.get("text") for item in content
             if isinstance(item, dict) and item.get("type") == "text"),
            None,
        )

        if not tool_text:
            return [(None, None)]

        return _parse_you_search_results(tool_text, top_n) or [(None, None)]

    except Exception as e:
        print(f"You.com Search error\nEndpoint used: {url}\nError details: {e}")
        return [(None, None)]    # fail-safe, same contract as keyword_search


# Testing tools
if __name__ == "__main__":
    print(check_youcom_connection())
    print(youcom_search("latest OpenSSH vulnerability writeups"))
