# use JSON to store and retrieve api_keys, api_models and more

import json
from pathlib import Path
from typing import List, Dict, Any, Optional

# --- CONFIG FILE PATH (Relative to this module's directory) ---
CONFIG_FILE = Path(__file__).resolve().parent / "api.config.json"


# --- CENTRAL CONFIG FILE MANAGEMENT ---

def _load_config() -> Dict[str, Any]:
    """Reads JSON config. Creates a new file with default data if missing or corrupted."""

    default_data = {
        "default_model": "gemini-2.5-flash",
        "gemini": {
            "api_key": "GEMINI_API_KEY",
            "default_model": "gemini-2.5-flash",
            "models": ["gemini-2.5-flash", "gemini-2.5-pro", "gemini-1.5-flash-latest"]
        },
        "chatgpt": {
            "api_key": "OPENAI_API_KEY",
            "default_model": "gpt-4o",
            "models": ["gpt-4o-mini", "gpt-4o", "gpt-3.5-turbo"]
        },
        "ollama": {
            "api_key": "http://localhost:11434",  # URL for Ollama
            "default_model": "llama3",
            "models": ["llama3", "mistral", "mixtral"]
        },
        "claude": {
            "api_key": "Anthropic_API_Key",
            "default_model": "claude-3-haiku",
            "models": [ "claude-3-haiku", "claude-3-opus", "claude-instant-100k"]
        },
        "openrouter": {
            "api_key": "OpenRouter_API_Key",
            "default_model": "kwaipilot/kat-coder-pro:free",
            "models": [
                "kwaipilot/kat-coder-pro:free"
            ]
        }
    }

    try:
        if not CONFIG_FILE.exists():
            raise FileNotFoundError  # Force creation if file doesn't exist

        with open(CONFIG_FILE, "r") as f:
            data = json.load(f)
            return data

    except (FileNotFoundError, json.JSONDecodeError):
        # File missing or corrupted, create it with default data
        print(f"[!] Config file missing or corrupted. Creating default config at: {CONFIG_FILE}")
        try:
            with open(CONFIG_FILE, "w") as f:
                json.dump(default_data, f, indent=4)
            return default_data
        except Exception as e:
            print(f"[!] FATAL: Could not create config file: {e}")
            return {}  # Return empty dict if writing fails


def _save_config(data: Dict[str, Any]) -> bool:
    """Writes the entire configuration dictionary back to the file."""
    try:
        with open(CONFIG_FILE, "w") as f:
            json.dump(data, f, indent=4)
        return True
    except Exception as e:
        print(f"[!] Error saving config file: {e}")
        return False


# --- CONFIGURATION ACCESS AND UPDATE FUNCTIONS ---

# Function 1: Read and return the global default AI model
def get_default_model() -> str:
    """Returns the globally configured default AI model string."""
    data = _load_config()
    return data.get('default_model', "gemini-2.5-flash")  # Fallback for safety

def get_default_provider():
    """Returns the AI provider associated with the global default model."""
    data = _load_config()
    default_provider = data.get('default_provider', 'gemini')  # Fallback to gemini for safety
    return default_provider

# Function 2: Update the global default AI model
def update_default_model(new_model: str) -> bool:
    """Updates the globally configured default AI model."""
    data = _load_config()
    data["default_model"] = new_model
    return _save_config(data)

def update_default_provider(new_provider: str) -> bool:
    """Updates the globally configured default AI provider."""
    data = _load_config()
    data["default_provider"] = new_provider
    return _save_config(data)

# Function 3: Read and return all available AI Vendors
def get_available_ais() -> List[str]:
    """Returns a list of all configured AI provider vendors (e.g., 'gemini', 'chatgpt')."""
    data = _load_config()
    # FIX: Use a list comprehension to exclude the 'default_model' key correctly
    return [k for k in data.keys() if k != 'default_model']


# Function 4: Read and return API key of a specific AI
def get_api_key(ai_name: str) -> Optional[str]:
    """Returns the API key for the specified AI vendor."""
    data = _load_config()
    return data.get(ai_name, {}).get("api_key")


# Function 5: Read and return default model of a specific AI
def get_ai_specific_default_model(ai_name: str) -> Optional[str]:
    """Returns the default model configured for a specific AI vendor."""
    data = _load_config()
    return data.get(ai_name, {}).get("default_model")


# Function 6: Read and return all models of a specific AI Vendor
def get_vendor_specific_all_models(ai_name: str) -> List[str]:
    """Returns a list of all known model names for the specified AI vendor."""
    data = _load_config()
    return data.get(ai_name, {}).get("models", [])


# Function 7: Update API key of a specific AI
def update_api_key(ai_name: str, new_key: str) -> bool:
    """Updates the API key for the specified AI vendor."""
    data = _load_config()
    if ai_name in data:
        data[ai_name]["api_key"] = new_key
        return _save_config(data)
    return False


# Function 8: Update default model of a specific AI
def update_ai_specific_default_model(ai_name: str, new_model: str) -> bool:
    """Updates the default model for the specified AI vendor, only if the model is known."""
    data = _load_config()
    if ai_name in data and new_model in data[ai_name].get("models", []):
        data[ai_name]["default_model"] = new_model
        return _save_config(data)
    return False


# --- ADDITIONAL UTILITIES (From your original list) ---

def add_ai_provider(ai_name: str, api_key: str, default_model: str, models: List[str]) -> bool:
    """Adds a new AI provider to the configuration file."""
    data = _load_config()
    data[ai_name] = {
        "api_key": api_key,
        "default_model": default_model,
        "models": models
    }
    return _save_config(data)


def remove_ai_provider(ai_name: str) -> bool:
    """Removes an AI provider from the configuration file."""
    data = _load_config()
    if ai_name in data:
        del data[ai_name]
        return _save_config(data)
    return False


if __name__ == "__main__":
    # Example usage for testing the functions
    print("--- TESTING CONFIG ACCESS ---")
    print("All Available AI's: ", get_available_ais())
    # print("Default model (Global): ", get_default_model())
    # print("Gemini API Key: ", get_api_key('gemini'))
    # print("Ollama Models: ", get_vendor_specific_all_models('ollama'))
    #
    # # Example update
    # print("\n--- TESTING UPDATE ---")
    # new_key = "ANTHROPIC-NEW-KEY-123"
    # print(f"Updating claude key...")
    # # Add Claude first if it's not in the default config for testing the update
    # add_ai_provider('claude', 'old-key', 'claude-3-haiku', ['claude-3-haiku', 'claude-3-opus'])
    #
    # update_api_key('claude', new_key)
    # print("Claude API Key (After Update): ", get_api_key('claude'))
    #
    # update_default_model('llama3')
    # print("Default model (Global, after update): ", get_default_model())