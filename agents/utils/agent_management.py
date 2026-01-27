#!/usr/bin/env python3
# HackerX - Agent Management Module
# file: agents/utils/agent_management.py
# Updated: 27 January 2026

from .agent_configs import get_default_model, get_available_ais, update_default_model, update_default_provider
from .agent_configs import get_vendor_specific_all_models, update_ai_specific_default_model
from .tools import get_available_tools_data
from .parse_n_print_response import get_console_width

from rich.console import Console
from rich.panel import Panel

import sys


# --- GLOBAL VARIABLES ---
DEFAULT_AI_MODEL: str
SELECTED_VENDOR: str
SELECTED_MODEL: str
ALL_AI_PROVIDERS = ["gemini", "chatgpt", "ollama"]  # FETCHED LATER FOR UPDATED LIST
AI_MANAGEMENT_OPTIONS = ["/change model", "/reset to default model", "/set vendor default model", "/list tools", "/help", "/exit", "/quit", "/bye"]
console = Console(width=get_console_width())


# --- COLOR CLASS ---
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

# get vendor name from number selected by user via mapping
def set_vendor_name():
    global SELECTED_VENDOR, ALL_AI_PROVIDERS

    # fetch all vendors
    ALL_AI_PROVIDERS = get_available_ais()
    print(f"""\n    {Colors.BOLD}{Colors.CYAN} Select a Vendor Product:{Colors.RESET}
            {Colors.YELLOW}1.{Colors.BOLD} Gemini (Google)
            {Colors.YELLOW}2.{Colors.BOLD} ChatGPT (OpenAI)
            {Colors.YELLOW}3.{Colors.BOLD} Ollama (Open Source)
            {Colors.YELLOW}4.{Colors.BOLD} Claude (Anthropic){Colors.RESET}
    """)

    while True:
        try:
            # Check the bounds of the input
            choice = int(input(f"   {Colors.CYAN}Enter Ur Choice{Colors.BOLD} ➤ {Colors.RESET} "))
            if 1 <= choice <= len(ALL_AI_PROVIDERS):
                break
            else:
                print(f"\n  {Colors.RED}Invalid - Enter a number between 1 and {len(ALL_AI_PROVIDERS)}.{Colors.RESET}")

        except ValueError:
            print(f"\n  {Colors.RED}Invalid - Please enter a number.{Colors.RESET}")

    # CRITICAL FIX: Use choice - 1 for 0-based indexing
    SELECTED_VENDOR = ALL_AI_PROVIDERS[choice - 1]
    print(f"\n  {Colors.GREEN}Vendor Selected: {Colors.BOLD}'{SELECTED_VENDOR}'{Colors.RESET}")
    return True

# set default model from vendor selected
def set_default_model(set_ai_specific_default=False):
    global SELECTED_MODEL
    # functions to use: update_default_model, update_ai_specific_default_model
    print(f"\n  {Colors.CYAN}Enter a model from {Colors.BOLD}{SELECTED_VENDOR}: {Colors.RESET}")

    # Get Vendor specific all models and list them for selection
    vendor_specific_all_models = get_vendor_specific_all_models(SELECTED_VENDOR)
    if not vendor_specific_all_models:
        print(f"\n  {Colors.RED}Error: No models available for {SELECTED_VENDOR}.{Colors.RESET}")
        return False

    for model in vendor_specific_all_models:
        print(f"        {vendor_specific_all_models.index(model) + 1}. {model}")

    while True:
        try:
            choice = int(input(f"\n {Colors.CYAN}Enter Ur Specific Model Number {Colors.BOLD}➤ {Colors.RESET}"))
            SELECTED_MODEL = vendor_specific_all_models[choice - 1]
            break
        except (ValueError, IndexError):  # Handle both bad input and out-of-range numbers
            print(f"\n  {Colors.RED}Invalid - Enter a number from the listing (1 to {len(vendor_specific_all_models)}).{Colors.RESET}")

    # set the model to tool default
    if set_ai_specific_default:
        updated = update_ai_specific_default_model(SELECTED_VENDOR, SELECTED_MODEL)
    else:
        updated = update_default_model(SELECTED_MODEL) and update_default_provider(SELECTED_VENDOR)

    if updated:
        print(f"\n  {Colors.GREEN}Model changed to {Colors.BOLD}{SELECTED_VENDOR}/{SELECTED_MODEL}{Colors.RESET}")
        return True
    else:
        print(f"\n  {Colors.RED}Failed to change model to {Colors.BOLD}{SELECTED_VENDOR}/{SELECTED_MODEL}{Colors.RESET}")
        return False

# change AI model
def change_ai_model():
    global DEFAULT_AI_MODEL, SELECTED_VENDOR
    DEFAULT_AI_MODEL = get_default_model()
    print(f"\n  {Colors.CYAN}Current Default AI Model: {Colors.BOLD}{DEFAULT_AI_MODEL}{Colors.RESET}")

    updated = False
    while not updated:
        set_vendor_name()
        updated = set_default_model()
        SELECTED_VENDOR = None  # reset for next iteration if needed

def reset_ai_model_to_default():
    """Setting AI Model to default model - 'gemini-2.5-flash' """

    global DEFAULT_AI_MODEL
    DEFAULT_AI_MODEL = get_default_model()
    data = f"\n [+] Current Default AI Model » {Colors.BOLD}{DEFAULT_AI_MODEL}{Colors.RESET}"

    DEFAULT_AI_MODEL = "gemini-2.5-flash"
    max_attempts = 10
    attempt = 0
    while attempt < max_attempts:
        updated = update_default_model(DEFAULT_AI_MODEL)
        updated = update_default_provider("gemini")
        if updated:
            data += f"\n{Colors.GREEN} [✓] Reset Success :{Colors.RESET} Default AI Model Now » {Colors.BOLD}{DEFAULT_AI_MODEL}{Colors.RESET}"
            console.print(Panel(data, title="( HackerX - Reset to Default Model )", border_style="blue", padding=(1, 2)))
            break
        attempt += 1

    if attempt >= max_attempts:
        data += f"\n{Colors.RED} [!] Failed to reset model after maximum attempts.{Colors.RESET}"
        console.print(Panel(data, title="( HackerX - Reset to Default Model )", border_style="red", padding=(1, 2)))


def print_all_available_tools():
    tools = get_available_tools_data()
    data = "\n".join([f"   ◈ {Colors.YELLOW}{name}{Colors.RESET}: {desc} " for name, desc in tools.items()])
    console.print(Panel(data, title="( HackerX - Available Tools )", border_style="blue", padding=(1, 2)))


def print_agent_management_options():
    help_text = f"""
    {Colors.BOLD}{Colors.CYAN}Model Management Commands:{Colors.RESET}\n
            {Colors.YELLOW}'/change model'{Colors.RESET}                  - Change the current default AI model to other available models
            {Colors.YELLOW}'/reset to default model'{Colors.RESET}        - Reset Current Model to the default Built-in AI model (gemini-2.5-flash)
            {Colors.YELLOW}'/set vendor default model'{Colors.RESET}      - Set the default model for a Specific AI vendor (e.g. Gemini(google))
    
    {Colors.BOLD}{Colors.CYAN}General Commands:{Colors.RESET}\n
            {Colors.YELLOW}'/list tools'{Colors.RESET}                    - List all available tools for HackerX agents
            {Colors.YELLOW}'/help'{Colors.RESET}                          - Show this help message
            {Colors.YELLOW}'/exit' | '/quit' | '/bye'{Colors.RESET}       - Exit the HackerX agent
            {Colors.YELLOW}other input or prompt{Colors.RESET}            - Interact with the AI agent using normal prompts
            """
    console.print(Panel(help_text, title="( HackerX - Help )", border_style="blue", padding=(1, 2), subtitle="[ Use these commands while in 'Interaction Mode' with agents! ]"))


def agent_management(task):
    match task:
        # change default model to user specified model
        case "/change model":
            change_ai_model()

        # reset model to built-in default model
        case "/reset to default model":
            reset_ai_model_to_default()

        # set vendor specific default model
        case "/set vendor default model":
            set_vendor_name()
            set_default_model(set_ai_specific_default=True)

        # list all available tools
        case "/list tools":
            print_all_available_tools()

        case "/help":
            print_agent_management_options()

        case "/exit" | "/quit" | "/bye":
            print(f"\n  {Colors.GREEN}Exiting HackerX. See you later!{Colors.RESET}")
            sys.exit(0)

        case _:
            print("Unknown command")

if __name__ == "__main__":
    # print(agent_management('/change-model'))
    # print(agent_management('/reset-model'))
    # print(agent_management('/list-tools'))
    print(agent_management('/help'))
