# !/bin/python3

# KaliGPT v1.3 (HackerX)
# /agents/__main__.py
# Set or Store user API keys & launch default model agent
# Last Modified: 27 January 2026

import sys
import subprocess
from .utils.agent_configs import update_api_key, get_available_ais, get_default_provider


# --- Set API key ---
def set_api_keys():
    try:
        available_ais = get_available_ais()[1:]

        ais = ""
        for ai in available_ais:
            ais += f"{available_ais.index(ai) + 1}. {ai}\n"
        print(f"Available AI Vendors:\n{ais}")
        selected = int(input("Select AI Vendor by number: ")) - 1
        if 0 <= selected < len(available_ais):
            selected_ai = available_ais[selected]
            new_key = input(f"Enter new API key for {selected_ai}: ")
            if update_api_key(selected_ai, new_key):
                print(f"[+] API key for {selected_ai} updated successfully.")
            else:
                print(f"[!] Failed to update API key for {selected_ai}.")
        else:
            print("[!] Invalid selection.")

    except KeyboardInterrupt:
        print("\nSee You,\nExiting Setup - KeyBoardInterrupt")


def main(args):

    match args:
        case ["--setup-keys"]:
            set_api_keys()

        case _:
            default_model = get_default_provider()
            prompt: str = "Are you Ready for Hacking?"
            if len(args) > 0 and args[0].strip():
                prompt = args[0]

            command = ["python", "-m", f"agents.{default_model}", prompt]
            print(f"[+] Launching KaliGPT with default model: {default_model} & prompt: {prompt}")

            try:
                # using python -m agents.agent_module_name to launch the agent
                # print(f"Running command: {' '.join(command)}")
                subprocess.run(command)

            except Exception as e:
                print(f"Exception occurred: {e}")

            except KeyboardInterrupt:
                print("\n\n")   # MSG already printed by running agent module

if __name__ == "__main__":
    # print(sys.argv[1:])
    main(sys.argv[1:])
