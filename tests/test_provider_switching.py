"""Tests for the provider switching utility and config management."""

import json
import pytest
from pathlib import Path
from agents.utils.agent_configs import _load_config, _save_config, update_default_provider, update_default_model


class TestAgentConfigsAndSwitching:
    """Verify config loading, saving, and provider switching."""

    def test_load_config_structure(self):
        config = _load_config()
        assert isinstance(config, dict)
        assert "default_provider" in config
        assert "default_model" in config
        assert "gemini" in config
        assert "openrouter" in config
        assert "ollama" in config
        assert "chatgpt" in config

    def test_update_default_provider(self):
        original_provider = _load_config().get("default_provider", "openrouter")
        try:
            assert update_default_provider("chatgpt") is True
            assert _load_config().get("default_provider") == "chatgpt"
        finally:
            update_default_provider(original_provider or "openrouter")

    def test_update_default_model(self):
        original_model = _load_config().get("default_model", "gpt-4o")
        try:
            assert update_default_model("gpt-4o") is True
            assert _load_config().get("default_model") == "gpt-4o"
        finally:
            update_default_model(original_model or "gpt-4o")
