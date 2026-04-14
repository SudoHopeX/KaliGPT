#!/usr/bin/env python3
# HackerX - Interactive Agent Management Module
# file: agents/utils/agent_management.py
# Updated: 21 March 2026

from .agent_configs import get_default_model, get_available_ais, update_default_model, update_default_provider
from .agent_configs import get_vendor_specific_all_models, update_ai_specific_default_model, get_api_key
from .tools.__init__ import get_available_tools_data
from .parse_n_print_response import get_console_width

from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.console import Group
from prompt_toolkit.shortcuts import radiolist_dialog

import sys
import requests



# --- GLOBAL VARIABLES ---
DEFAULT_AI_MODEL: str
SELECTED_VENDOR: str
SELECTED_MODEL: str
ALL_AI_PROVIDERS = ["gemini", "chatgpt", "ollama","openrouter"]  # FETCHED LATER FOR UPDATED LIST
AI_MANAGEMENT_OPTIONS = ["/change model", "/reset to default model", "/list tools", "/help", "/exit", "/quit", "/bye"]
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


def interactive_select(title, text, options):
    """
    Interactive select function.

    options = list of tuples:
    [
        (value, label)
    ]

    value -> returned when selected
    label -> shown in UI
    """

    result = radiolist_dialog(
        title=title,
        text=text,
        values=options
    ).run()

    return result

def fetch_ollama_local_models():
    """
    Fetch installed ollama models via local API
    """
    try:
        url = get_api_key("ollama")
        r = requests.get(f"{url}/api/tags", timeout=3)
        r.raise_for_status()
        data = r.json()

        return [m["name"] for m in data.get("models", [])]

    except Exception:
        return []

# get vendor name from number selected by user via mapping
def set_vendor_name():
    global SELECTED_VENDOR, ALL_AI_PROVIDERS

    options = [(ai, ai) for ai in get_available_ais()]
    selected = interactive_select(
        title="HackerX Vendor Selection",
        text="Usages: Use Arrow keys then ENTER to select model, TAB to switch..",
        options=options
    )

    if not selected:
        print(f"{Colors.RED}Vendor selection cancelled{Colors.RESET}")
        return False

    SELECTED_VENDOR = selected

    print(f"\n  {Colors.GREEN}Vendor Selected: {Colors.BOLD}{SELECTED_VENDOR}{Colors.RESET}")

    return True


# set default model from vendor selected
def set_default_model():
    global SELECTED_MODEL

    vendor_specific_all_models = list(
        get_vendor_specific_all_models(SELECTED_VENDOR)
    )

    if SELECTED_VENDOR.lower() == "ollama":
        ollama_models = fetch_ollama_local_models()

        for m in ollama_models:
            if m not in vendor_specific_all_models:
                vendor_specific_all_models.append(m)

    if not vendor_specific_all_models:
        print(f"{Colors.RED}No models available{Colors.RESET}")
        return False

    vendor_specific_all_models.append("Other (Add new)")

    options = [(v, v) for v in vendor_specific_all_models]

    selected = interactive_select(
        title=f"{SELECTED_VENDOR} Model Selection",
        text="Usages: Use Arrow keys then ENTER to select model, TAB to switch..",
        options=options
    )

    if not selected:
        print(f"{Colors.RED}Model selection cancelled{Colors.RESET}")
        return False

    if selected == "Other (Add new)":

        custom_model = input(
            f"{Colors.CYAN}Enter Model Name ➤ {Colors.RESET}"
        ).strip()

        if not custom_model:
            print(f"{Colors.RED}Invalid model{Colors.RESET}")
            return False

        SELECTED_MODEL = custom_model

    else:
        SELECTED_MODEL = selected

    updated = (
        update_ai_specific_default_model(SELECTED_VENDOR, SELECTED_MODEL)
        and update_default_model(SELECTED_MODEL)
        and update_default_provider(SELECTED_VENDOR)
    )

    if updated:
        print(
            f"\n{Colors.GREEN}Model changed → "
            f"{Colors.BOLD}{SELECTED_VENDOR}/{SELECTED_MODEL}{Colors.RESET}"
        )
        return True

    print(f"{Colors.RED}Failed to update model{Colors.RESET}")
    return False


# change AI model
def change_ai_model():
    global DEFAULT_AI_MODEL, SELECTED_VENDOR
    DEFAULT_AI_MODEL = get_default_model()
    print(f"\n  {Colors.CYAN}Current Default AI Model: {Colors.BOLD}{DEFAULT_AI_MODEL}{Colors.RESET}")

    updated = False
    attempt = 0
    while not updated and attempt <= 3:
        set_vendor_name()
        updated = set_default_model()
        SELECTED_VENDOR = None  # reset for next iteration if needed
        attempt += 1

    if not updated and attempt >= 3:
        print("Model Change failed. Try Again ( 3 attempts consumed )...")


def reset_ai_model_to_default():
    """Setting AI Model to default model - 'gemini-2.5-flash' """

    global DEFAULT_AI_MODEL
    DEFAULT_AI_MODEL = get_default_model()
    data = f"\n [+] Current Default AI Model » {Colors.BOLD}{DEFAULT_AI_MODEL}{Colors.RESET}"

    DEFAULT_AI_MODEL = "gemini-2.5-flash"
    max_attempts = 10

    for attempt in range(max_attempts):
        if update_default_model(DEFAULT_AI_MODEL) and update_default_provider("gemini"):
            data += f"\n{Colors.GREEN} [✓] Reset Success :{Colors.RESET} Default AI Model Now » {Colors.BOLD}{DEFAULT_AI_MODEL}{Colors.RESET}"
            console.print(Panel(data, title="( HackerX - Reset to Default Model )", border_style="blue", padding=(1, 2)))
            break

        if attempt == max_attempts - 1:
            data += f"\n{Colors.RED} [!] Failed to reset model after maximum attempts.{Colors.RESET}"
            console.print(Panel(data, title="( HackerX - Reset to Default Model )", border_style="red", padding=(1, 2)))


def print_all_available_tools():
    tools = get_available_tools_data()
    table = Table(title="Available Tools", title_style="cyan", box=None)
    for name, desc in tools.items():
        table.add_row(f"   ◈ {Colors.YELLOW}{name}{Colors.RESET} :", desc)

    console.print(
        Panel(
            table,
            title="( HackerX - Available Tools )",
            border_style="blue",
            padding=(1, 2)
        )
    )


def print_agent_management_options():

    table1 = Table(title="Model Management Commands", title_style="cyan", title_justify="left", show_header=False, box=None)
    table1.add_row(f"{Colors.YELLOW}/change model{Colors.RESET}", "Change default AI model")
    table1.add_row(f"{Colors.YELLOW}/reset to default model{Colors.RESET}", "Reset to built-in model")
    table1.add_row("", "")

    table2 = Table(title="General Commands", title_style="cyan", title_justify="left", show_header=False, box=None)
    table2.add_row(f"{Colors.YELLOW}'/list tools'{Colors.RESET}", "List all available tools for HackerX agents")
    table2.add_row(f"{Colors.YELLOW}'/help'{Colors.RESET}", "Show this help message and exit{Colors.RESET}")
    table2.add_row(f"{Colors.YELLOW}'/exit' | '/quit' | '/bye'{Colors.RESET}", "Exit HackerX agent")
    table2.add_row(f"{Colors.YELLOW}other input or prompt{Colors.RESET}", "Interact with the AI agent using prompts")

    console.print(
        Panel(
            Group(table1, table2),
            title="( HackerX - Help )",
            border_style="blue",
            padding=(1, 2),
            subtitle="[ Use these commands while in 'Interaction Mode' with agents! ]",
        ))


def agent_management_options():
    print_agent_management_options()
    options = [
        ("/change model",           "/change model            →  Change default AI model"),
        ("/reset to default model", "/reset to default model  →  Reset to built-in model"),
        ("/list tools",             "/list tools              →  List all available tools"),
        ("/help",                   "/help                    →  Show help menu"),
        ("/exit",                   "/exit                    →  Exit HackerX")
    ]

    selected = interactive_select(
        title="HackerX Help Menu",
        text="Usages: Use Arrow keys then ENTER to select model, TAB to switch..",
        options=options
    )

    if selected:
        agent_management(selected)

def agent_management(task):
    match task:
        # change default model to user specified model
        case "/change model":
            change_ai_model()

        # reset model to built-in default model
        case "/reset to default model":
            reset_ai_model_to_default()


        # list all available tools
        case "/list tools":
            print_all_available_tools()

        case "/help":
            agent_management_options()

        case "/exit" | "/quit" | "/bye":
            print(f"\n  {Colors.GREEN}Exiting HackerX. See you later!{Colors.RESET}")
            sys.exit(0)

        case _:
            print("Unknown command")

if __name__ == "__main__":
    # print(agent_management('/change model'))
    # print(agent_management('/reset model'))
    # print(agent_management('/list tools'))
    print(agent_management('/help'))
