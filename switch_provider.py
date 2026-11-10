import sys
import json
from pathlib import Path

def switch_provider(provider_name):
    config_path = Path("agents/utils/api.config.json")
    if not config_path.exists():
        print(f"[!] Error: {config_path} not found.")
        return
    
    data = json.loads(config_path.read_text())
    if provider_name not in data:
        print(f"[!] Error: Provider '{provider_name}' not found in configuration. Available: {list(data.keys())}")
        return
    
    data["default_provider"] = provider_name
    if "default_model" in data[provider_name]:
        data["default_model"] = data[provider_name]["default_model"]
        
    config_path.write_text(json.dumps(data, indent=4))
    print(f"[+] Successfully switched default provider to: {provider_name} (default model: {data.get('default_model')})")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 switch_provider.py <provider_name>")
        print("Supported providers: gemini, chatgpt, ollama, openrouter")
        sys.exit(1)
    switch_provider(sys.argv[1])
