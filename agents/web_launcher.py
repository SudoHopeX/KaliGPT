# agents/web_launcher.py
# KaliGPT v1.3 - AI Web-Chat Launcher (Opener) Agent
# SudoHopeX ( https://github.com/SudoHopeX )
# Last Modified: 10 January 2026
# Tested on: Kali Linux

# --- IMPORTS ---
import sys
import os
import json
import subprocess
import argparse


# --- GLOBAL VARIABLES ---
JSON_FILE_PATH = os.path.join(os.path.dirname(__file__), "utils", "web_launcher.json")

class Colors:
    """ANSI color codes for terminal output."""
    RESET = '\033[0m'

    # Foreground Colors
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    CYAN = '\033[96m'
    RED = '\033[91m'

    # Styles
    BOLD = '\033[1m'


# -- JSON HANDLING FUNCTIONS --
def get_json_data():
    """Reads and returns the data from the JSON configuration file.
    Returns:
        dict: The data from the JSON file.
    """
    try:
        with open(JSON_FILE_PATH, "r") as file:
            return json.load(file)

    except FileNotFoundError as e:
        print(f"\n{Colors.RED}[!] Config File Not found, ", e, Colors.RESET)
        return {}

def save_json_data(config):
    """Saves the models configuration to JSON file.
    Args:
        config (dict): The models configuration to save.
    """
    try:
        with open(JSON_FILE_PATH, "w") as file:
            json.dump(config, file, indent=4)
    except Exception as e:
        print(f"\n{Colors.RED}[!] Error saving models configuration: {e} {Colors.RESET}")


# -- SPECIFIC DATA RETRIEVAL FUNCTIONS FROM JSON --
def get_default_browser_to_use():
    """Retrieves the default web browser from AI-specific settings.
    Returns:
        str: The default web browser command.
    """
    data = get_json_data()
    return data["web-browser"]["default"]

def get_default_model():
    """Retrieves the default web model from AI-specific settings.
    Returns:
        str: The default web model URL.
    """
    data = get_json_data()
    return data["model"]["default"]

def get_urls():
    """Retrieves the available web model url's from the JSON configuration.
    Returns:
        dict: A dictionary of available web models.
    """
    data = get_json_data()
    return data["model"]["urls"]

# -- MAIN FUNCTIONALITY --
def change_config(change_browser: bool = False, change_model: bool = False):
    """Changes the default web browser or model based on user input.
    Args:
        change_browser (bool): Whether to change the default web browser.
        change_model (bool): Whether to change the default web model.
    """

    if change_browser:
        default_browser = int(input(f"""\n{Colors.CYAN}Choose your default web browser:{Colors.RESET}
                1. chromium
                2. firefox   [ Default ]
                3. google chrome
                4. brave
                5. safari

                {Colors.CYAN}Enter your choice {Colors.BOLD}(1-5){Colors.RESET}: """).strip())
        browser_options = {
            1: "chromium",
            2: "firefox",
            3: "google-chrome",
            4: "brave-browser",
            5: "safari"
        }
        default_browser = browser_options.get(default_browser, "firefox")

        # changing default browser in JSON file
        config = get_json_data()
        config["web-browser"]["default"] = default_browser
        save_json_data(config)
        print(f"\n{Colors.GREEN}Default Browser set to: {Colors.BOLD}{default_browser} {Colors.RESET}")

    if change_model:
        models = get_urls().keys()
        available_models = "\n".join([f"                {i}. {model}" for i, model in enumerate(models, start=1)])
        available_models = available_models.replace("chatgpt", "chatgpt [ Default ]")
        available_models += "\n                5. other (to add new model, must have URL)"

        new_model = int(input(f"""\n{Colors.CYAN}Choose your default web model:{Colors.RESET}\n{available_models}

                {Colors.CYAN}Enter Your Choice {Colors.BOLD}(1-5){Colors.RESET}: """))

        # consolidating model options from models list
        model_options = {}
        for i in range(1, len(models) + 1):
            model_options[i] = list(models)[i - 1]
        model_options[len(model_options) + 1] = "other"

        # model_options = {
        #     1: "chatgpt",
        #     2: "gemini",
        #     3: "claude",
        #     4: "openrouter",
        #     5: "other"
        # }
        new_model = model_options.get(new_model, "chatgpt")
        config = get_json_data()

        if new_model == "other":
            new_model = input("\nEnter the name for the new default web model: ").strip()
            new_model_url = input("\nEnter the URL for the new default web model: ").strip()

            # adding new model to JSON file
            config["model"]["default"] = new_model
            config["model"]["urls"][new_model] = new_model_url

        else:
            config["model"]["default"] = new_model

        save_json_data(config)
        print(f"\n{Colors.GREEN}Default Web Model set to: {Colors.BOLD}{new_model} {Colors.RESET}")


    # Exit after changing configuration
    sys.exit(0)


def launch_web_browser(prompt: str, model = None):
    """Launches the specified web browser with a given prompt URL.
    Args:
        prompt (str): The prompt or query to be appended to the URL.
        model (str): The AI model to determine which URL to use.
    """
    model_urls = get_urls()
    browser = get_default_browser_to_use()

    if model:
        if model in model_urls:
            model_url = model_urls[model]
        else:
            default_model = get_default_model()
            print(f"\n{Colors.YELLOW}[!] Model '{model}' not found. Using default model '{default_model}'.{Colors.RESET}")
            model = default_model
            model_url = model_urls[model]
    else:
            model = get_default_model()
            model_url = model_urls.get(model)

    try:
        # launching web browser with the constructed URL
        print(f"\nOpening '{model}' Web Chat on '{browser}'...")
        subprocess.run([browser, model_url + prompt], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    except FileNotFoundError:
        print(f"\n{Colors.RED}[!] Web browser '{browser}' not found. Please check your configuration or install it.{Colors.RESET}")
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}[!] Exiting, Thanks for utilizing me (^.^).{Colors.RESET}")
    except Exception as e:
        print(f"\n{Colors.RED}[!] Error launching web browser: {e} {Colors.RESET}")


# -- Main function --
def main(args):
    """Main function to handle command-line arguments and INVOKE appropriate actions."""

    if args.change_browser or args.change_model:
        # changing default browser or model
        change_config(change_browser=args.change_browser, change_model=args.change_model)

    else:
        # launching web browser with specified model and prompt
        model = get_default_model() if args.model == "default" else args.model
        prompt = args.prompt or ""

        launch_web_browser(prompt=prompt, model=model)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="\n     kaligpt --web",
        description="Description: \n     KaliGPT v1.3 AI Web-chat Launcher Agent",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("-m", "--model", type=str, help="Specify the AI web model to use (e.g., chatgpt, gemini, claude).", default="default")
    parser.add_argument("-p", "--prompt", type=str, help="The prompt or query to send to the AI model.", default="")
    parser.add_argument("--change-browser", action="store_true", help="Change the default web browser.")
    parser.add_argument("--change-model", action="store_true", help="Change the default web model.")
    main(args=parser.parse_args())
