#!/bin/bash

# Coded by SudoHopeX | Krishna Dwivedi 
# Must use it for Ethical Use only 


trap "kill $SPIN_PID 2>/dev/null" EXIT

TARGET_HOME=$(eval echo ~$(logname))

# Spinner function
spin() {

  local msg="$1"
  local -a marks=( '-' '\' '|' '/' )
  while :; do
    for mark in "${marks[@]}"; do
      printf "\r\e[1;32m[+] $msg...\e[0m %s" "$mark"
      sleep 0.1
    done
  done
}

# Spinner starter (background-safe)
start_spinner() {
  spin "$1" &
  SPIN_PID=$!
}

# Spinner stopper (safe kill)
stop_spinner() {
  kill $SPIN_PID 2>/dev/null
  wait $SPIN_PID 2>/dev/null
  echo -e "\r\e[1;32m[✓] $1 complete! \e[0m"
}

# installing dependencies if not found on system
install_if_missing() {
        local pkg="$1"

        if ! dpkg -s $pkg >/dev/null 2>&1; then

                start_spinner "$pkg Installing..."
                sudo apt-get install $pkg -y > /dev/null 2>&1
                stop_spinner "$pkg Installation"

        else
                echo  -e "\e[33m$pkg Installation found...\e[0m"
        fi
}

# model defaults
MODEL_CHOICE=""
UNINSTALL_MODE=""
SHOW_MODELS=false

# print list models
print_models() {
echo -e "\e[1;33mKaliGPT MODELs:\e[0m"
echo "   1) OpenAI ChatGPT ( OpenAI, Free, Online ) [ Requires API KEY ]"
echo "   2) Mistral    ( Free, Offline - Min 6GB Data Required)"
echo "   3) Llama      ( Free, Offline )"
echo "   4) KaliGPT -web based ( OpenAI, Free, Online )"
echo "   5) Gemini-2.5 Flash (Google, Free, Online) [ Requires API Key ]"
echo ""
echo "      [Note: opttion 4 required 1 time logging & keep logged in config in chromium if not]"
}

# print KaliGPT Installer script uses
print_installer_usages() {
  echo -e "\e[1;33mKaliGPT Installer commands:\e[0m"
  echo "   --model <model-num>         -  install a specific model"
  echo "   --listmodels                -  list available models"
  echo "   --uninstall-m <model-num>   -  uninstall a specific model"
  echo "   --uninstall                 -  uninstall KaliGPT (everything)"
  echo "   --help                      -  print this usage info"
  echo ""
  print_models
  echo ""
  echo -e "\e[1;33mUsages Examples:\e[0m"
  echo "   sudo bash kaligpt_unified.sh --model 1       # install OpenAI ChatGPT4.0 with API access"
  echo "   sudo bash kaligpt_unified.sh --model 2       # install KaliGPT (Mistral AI locally)"
  echo "   bash kaligpt_unified.sh --help               # print script usages"
  echo "   sudo bash kaligpt_unified.sh --uninstall-m 1 # uninstall OpenAI installed files"
  echo "   sudo bash kaligpt_unified.sh --uninstall     # uninstall KaliGPT (everything)"
}


# unistall a model
uninstall_model() {
    case "$1" in
        1)
            UNINSTALL_MODEL="ChatGPT"
            PY_FILE="/opt/KaliGPT/kaligpt_chatgpt4o.py"
            ;;
        2)
            UNINSTALL_MODEL="Mistral"
            PY_FILE="/opt/KaliGPT/kaligpt_mistral.py"
            ;;
        3)
            UNINSTALL_MODEL="Llama"
            PY_FILE="/opt/KaliGPT/kaligpt_llama.py"
            ;;
        4)
            echo "To uninstall ChatGPT Web launcher, install KaliGPT itself."
            exit 0
            ;;
        5)
            UNINSTALL_MODEL="Gemini"
            PY_FILE="/opt/KaliGPT/kaligpt_gemini.py"
            ;;
        *)
            echo "Invalid uninstall option: $1"
            exit 0
            ;;
    esac

    echo "[*] Removing Model: $UNINSTALL_MODEL"
    if [[ -f "$PY_FILE" ]] ; then
      sudo rm -f "$PY_FILE"  # Remove the file if already present
    else
      echo "Model Installation not found!"
      exit 0
    fi

    echo "[✓] Uninstall of Model: $UNINSTALL_MODEL complete."
    exit 0
}


# uninstall KaliGPT ( everything )
uninstall_kaligpt() {
    start_spinner "Uninstalling KaliGPT..."
    sudo rm -rf /opt/KaliGPT
    sudo rm -rf /usr/local/bin/kaligpt
    stop_spinner "KaliGPT Uninstall"
    echo -e "\e[1;31mKaliGPT & all its files have been uninstalled Successfull\e[0m"

    read -p "Uninstall Ollama [Y(yes)/N(no)]: " UNINSTALL_OLLAMA

    # Convert input to lowercase for case-insensitive comparison
    case "$UNINSTALL_OLLAMA" in
          y|Y|yes|YES|"")

		start_spinner "Uninstalling Ollama..."

        	# Stop and disable the service
        	sudo systemctl stop ollama 2>/dev/null || true
        	sudo systemctl disable ollama 2>/dev/null || true

        	# Remove the service file
        	sudo rm -f /etc/systemd/system/ollama.service

        	# Reload systemd
        	sudo systemctl daemon-reload

        	# Remove the binary (common install locations)
        	sudo rm -f /usr/bin/ollama
        	sudo rm -f /usr/local/bin/ollama

        	# Remove data and model storage
        	sudo rm -rf /usr/share/ollama

        	# Remove user and group (ignore if they don't exist)
        	sudo userdel ollama 2>/dev/null || true
        	sudo groupdel ollama 2>/dev/null || true

        	# Remove configuration and cache (per-user, optional)
        	rm -rf ~/.ollama

        	stop_spinner "Ollama has been uninstalled"
        	;;
    	*)
        	echo "Ollama Uninstall cancelled."
        	;;
    esac

    exit 0
}


# printing logo
echo ""
echo  -e "\e[1;32mKaliGPT v1.1     ~ SudoHopeX | Krishna Dwivedi\e[0m"
echo  -e "\e[1;32m[Contact SudoHopeX](https://sudohopex.github.io/)\e[0m"
echo ""

# argument parser
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --help)
            print_installer_usages
            exit 0
            ;;
        --model)
            MODEL_CHOICE="$2"
            shift
            ;;
        --list-models)
            SHOW_MODELS=true
            ;;
        --uninstall)
            # uninstall kaligpt everything
            uninstall_kaligpt
    	    ;;
        --uninstall-m)
            UNINSTALL_MODE="$2"
            shift
            ;;
        *)
            echo "[!] No argument specified"
	          echo " Use bash kaligpt_unified.sh --help to see usages"
            exit 1
            ;;
    esac
    shift
done


# Execute actions
if [ "$SHOW_MODELS" = true ]; then
    print_models
    exit 0
fi

if [ -n "$UNINSTALL_MODE" ]; then
    uninstall_model "$UNINSTALL_MODE"
fi

if [ -z "$MODEL_CHOICE" ]; then
    echo "No model specified. Use --model 1|2|3|4|5 to install a model"
    echo "Use --list-models to see available models or --help to see usages."
    exit 1
else
	case $MODEL_CHOICE in
    	1)
        	INSTALL_MODE="chatgpt"
        	MODEL_NAME="OpenAI GPT (Paid)"
        	;;
    	2)
        	INSTALL_MODE="mistral"
        	MODEL_NAME="Mistral (Free, Local)"
        	;;
    	3)
        	INSTALL_MODE="llama"
        	MODEL_NAME="LLaMA (Free, Local)"
        	;;
      4)
        INSTALL_MODE="kaligpt-web"
        ;;
      5)
        INSTALL_MODE="gemini"
        ;;
    	*)
        echo "Invalid model selection."
        exit 1
        ;;
	esac
fi


start_spinner "System Updating"
sudo apt update > /dev/null 2>&1
stop_spinner "System Update"

# checking and installing missing pkgs
install_if_missing python3
install_if_missing python3-pip
install_if_missing python3-venv
install_if_missing curl

# creating a venv for running python and pip3
sudo python3 -m venv /opt/KaliGPT
source /opt/KaliGPT/bin/activate
cd /opt/KaliGPT/

if ! [[ -f "/opt/KaliGPT/kaligpt_unified.sh" ]] ; then
  INSTALLER_PATH=$(find "$TARGET_HOME" -type f -name "kaligpt_unified.sh" -print -quit)
	sudo cp -r "$INSTALLER_PATH" "/opt/KaliGPT/"  # Copying Installer to /opt/KaliGPT/ dir
fi

if ! [[ -f "/opt/KaliGPT/kconfig.py" ]] ; then
  CONFIG_PATH=$(find "$TARGET_HOME" -type f -name "kconfig.py" -print -quit)
	sudo cp -r "$CONFIG_PATH" "/opt/KaliGPT/"  # Copying Installer to /opt/KaliGPT/ dir
fi

case "$INSTALL_MODE" in

	chatgpt)
		echo "Installing KaliGPT ( ChatGPT-4o = OpenAI API required!)"

		# asking for OpenAI API Key to install GPT4
    echo ""
    echo -e "\e[31mEnter OpenAI API Key to Install KaliGPT...\e[0m"
    echo -e "\e[33mIf not created one yet then,\e[0m"
    echo -e "\e[33m1. SignIn/Login to Openai & visit: https://platform.openai.com/account/api-keys\e[0m"
    echo -e "\e[33m2. Click “Create new secret key”\e[0m"
    echo -e "\e[33m3. Copy and save the key somewhere secure and enter below\e[0m"
    echo -e "\e[1;31mNOTE: You must have a paid plan to use OpenAI API key!\e[0m"
    read -p "Enter your OpenAI API Key:" OPENAI_API_KEY

    if [[ -n "$USER_KEY" ]]; then
        sed -i "s|OPENAI_API_KEY = None|OPENAI_API_KEY = \"${OPENAI_API_KEY}\"|" kconfig.py
        echo "[*] OpenAI API Key saved to kconfig"
    else
        echo -e "\e[1;31m[!] No API Key entered. You can edit /opt/KaliGPT/kconfig.py later to add it.\e[0m"
    fi

		start_spinner "pip requirements Installing"
    pip3 install openai rich> /dev/null 2>&1
    stop_spinner "pip Requirements Installation"

		cat <<'PYCODE' | envsubst '$OPENAI_API_KEY' | sudo tee kaligpt_chatgpt4o.py > /dev/null
#!/usr/bin/env python3

#kaligpt_chatgpt4o.py
from openai import OpenAI
import sys
from rich.console import Console
from rich.text import Text
from rich.panel import Panel
from rich.syntax import Syntax
import re
import os
import kconfig

# CONFIGs
client = OpenAI(
      api_key = kconfig.OPENAI_API_KEY
)

MODEL = "gpt-4o"

# Custom system prompt for professional GPT
f"""
You are a professional assistant (named 'HopeX') for Linux users, cybersecurity researchers, bug bounty hunters, and ethical hackers.
You are specialized in Kali Linux tools, penetration testing, Bug Bounty Hunting, CTFs, and Linux system administration.
Respond with expert-level detail, real examples, and CLI commands when appropriate. Focus on practical use.

Return a greetings in ask of greetings like hii, hello, how are you, etc is user prompts.

and explain the asked topic."""

def ask_chatgpt(user_prompt):

      response = client.responses.create(
                       model=MODEL,
                       instructions=SYSTEM_PROMPT,
                       input=user_prompt
                  )

      return response.output_text

def get_terminal_size():
    # Get the current terminal size
    try:
        # This works on most operating systems
        terminal_size = os.get_terminal_size()
        console_width = terminal_size.columns
    except OSError:
        # Fallback if unable to determine terminal size
        console_width = 101

    return console_width

def parse_n_print_response(api_response_text):

    # Initialize the rich Console
    console = Console(width=get_terminal_size())

    # Split the response into sections based on markdown headings
    sections = re.split(r'### (.+?)\n|#### (.+?)\n', api_response_text)
    sections = [s for s in sections if s and not s.isspace()]  # Remove empty entries

    # Iterate through sections and print with enhanced formatting
    for section in sections:
        # Check for main headings (e.g., "Hello, Explain Ethical Hacking!")
        if section.startswith('**'):
            title = section.replace('**', '').strip()
            console.print(f"\n[bold green]{title}[/bold green]\n", style="italic")
        # Check for subheadings (e.g., "Key Concepts and Principles:")
        elif section.startswith('**'):
            title = section.replace('**', '').strip()
            console.print(f"\n[bold blue]{title}[/bold blue]\n")
        else:
            # Split the content by lines
            lines = section.strip().split('\n')

            # Process each line for special formatting
            formatted_lines = []
            in_code_block = False

            for line in lines:
                # Handle code blocks
                if line.strip() == '```bash':
                    in_code_block = True
                    continue
                elif line.strip() == '```':
                    in_code_block = False
                    continue

                if in_code_block:
                    formatted_lines.append(line)
                else:
                    # Replace markdown bold and italic with rich styles
                    line = re.sub(r'\*\*(.+?)\*\*', '[bold]\\1[/bold]', line)
                    line = re.sub(r'\*(.+?)\*', '[italic]\\1[/italic]', line)
                    line = re.sub(r'`([^`]+)`', '[purple]\\1[/purple]', line)  # Highlight inline code

                    # Check for bullet points
                    if line.strip().startswith('*'):
                        formatted_lines.append(f"  [yellow]•[/yellow] {line.strip()[1:].strip()}")
                    elif line.strip().startswith('1.'):
                        formatted_lines.append(f"  [cyan]1.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('2.'):
                        formatted_lines.append(f"  [cyan]2.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('3.'):
                        formatted_lines.append(f"  [cyan]3.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('4.'):
                        formatted_lines.append(f"  [cyan]4.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('5.'):
                        formatted_lines.append(f"  [cyan]5.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('6.'):
                        formatted_lines.append(f"  [cyan]6.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('7.'):
                        formatted_lines.append(f"  [cyan]7.[/cyan] {line.strip()[2:].strip()}")

                    else:
                        formatted_lines.append(line)

            # Print the processed content
            if not in_code_block:
                console.print("\n".join(formatted_lines))
            else:
                code_block_content = "\n".join(formatted_lines)
                syntax = Syntax(code_block_content, "bash", theme="monokai", line_numbers=False)
                console.print(Panel(syntax, title="Code Example", border_style="dim"))


# MAIN FUNCTION to use GPT4
def main(prompt=None):

    print("㉿ KaliGPT (ChatGPT-4o) - by SudoHopeX|Krishna Dwivedi\n")
    print("㉿ KaliGPT: CyberSecurity Assistant")

    while True:
        try:
            if prompt:
                user_input = prompt
            else:
                user_input = input("Prompt: ")

            if user_input.lower() in ("exit", "quit", "q"):
                break

            reply = ask_chatgpt(user_input)

            print(f"㉿ KaliGPT: ")
            parse_n_print_response(reply)
            prompt = None

        except Exception as e:
            print(f"Error: {e}")
            break


if __name__ == "__main__":
    if len(sys.argv) > 1:
        args = ' '.join(sys.argv[1:])
        main(args)
    else:
        main()
PYCODE

		deactivate
		;;

	mistral)
		echo "Installing KaliGPT (Mistral AI, Offline)"

		# Installing Ollama to use mistral ai
		echo ""
		start_spinner "Installing Ollama Mistral AI"
		curl -fsSL https://ollama.com/install.sh | sh
		ollama pull mistral
		stop_spinner "Ollama Mistral AI Installation"

		echo ""
		start_spinner "pip requirements Installing"
		pip3 install -U requests rich> /dev/null 2>&1
		stop_spinner "pip Requirements Installation"

		sudo tee kaligpt_mistral.py > /dev/null <<'PYCODE'
#!/usr/bin/env python3

import sys
import requests
from rich.console import Console
from rich.text import Text
from rich.panel import Panel
from rich.syntax import Syntax
import re
import os

MODEL = "mistral"  # or llama3, codellama, etc.
OLLAMA_API_URL = f"http://localhost:11434/api/generate"

def ask_ollama(prompt):
    user_prompt = f"""
You are a professional assistant (named 'HopeX') for Linux users, cybersecurity researchers, bug bounty hunters, and ethical hackers.
You are specialized in Kali Linux tools, penetration testing, Bug Bounty Hunting, CTFs, and Linux system administration.
Respond with expert-level detail, real examples, and CLI commands when appropriate. Focus on practical use.

and explain:

{prompt}"""
    payload = {
        "model": MODEL,
        "prompt": user_prompt,
        "stream": False
    }

    try:
        response = requests.post(OLLAMA_API_URL, json=payload)
        response.raise_for_status()
        return response.json()["response"]

    except Exception as e:
        return f"Error: {e}"

def get_terminal_size():
    # Get the current terminal size
    try:
        # This works on most operating systems
        terminal_size = os.get_terminal_size()
        console_width = terminal_size.columns
    except OSError:
        # Fallback if unable to determine terminal size
        console_width = 101

    return console_width

def parse_n_print_response(api_response_text):

    # Initialize the rich Console
    console = Console(width=get_terminal_size())

    # Split the response into sections based on markdown headings
    sections = re.split(r'### (.+?)\n|#### (.+?)\n', api_response_text)
    sections = [s for s in sections if s and not s.isspace()]  # Remove empty entries

    # Iterate through sections and print with enhanced formatting
    for section in sections:
        # Check for main headings (e.g., "Hello, Explain Ethical Hacking!")
        if section.startswith('**'):
            title = section.replace('**', '').strip()
            console.print(f"\n[bold green]{title}[/bold green]\n", style="italic")
        # Check for subheadings (e.g., "Key Concepts and Principles:")
        elif section.startswith('**'):
            title = section.replace('**', '').strip()
            console.print(f"\n[bold blue]{title}[/bold blue]\n")
        else:
            # Split the content by lines
            lines = section.strip().split('\n')

            # Process each line for special formatting
            formatted_lines = []
            in_code_block = False

            for line in lines:
                # Handle code blocks
                if line.strip() == '```bash':
                    in_code_block = True
                    continue
                elif line.strip() == '```':
                    in_code_block = False
                    continue

                if in_code_block:
                    formatted_lines.append(line)
                else:
                    # Replace markdown bold and italic with rich styles
                    line = re.sub(r'\*\*(.+?)\*\*', '[bold]\\1[/bold]', line)
                    line = re.sub(r'\*(.+?)\*', '[italic]\\1[/italic]', line)
                    line = re.sub(r'`([^`]+)`', '[purple]\\1[/purple]', line)  # Highlight inline code

                    # Check for bullet points
                    if line.strip().startswith('*'):
                        formatted_lines.append(f"  [yellow]•[/yellow] {line.strip()[1:].strip()}")
                    elif line.strip().startswith('1.'):
                        formatted_lines.append(f"  [cyan]1.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('2.'):
                        formatted_lines.append(f"  [cyan]2.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('3.'):
                        formatted_lines.append(f"  [cyan]3.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('4.'):
                        formatted_lines.append(f"  [cyan]4.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('5.'):
                        formatted_lines.append(f"  [cyan]5.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('6.'):
                        formatted_lines.append(f"  [cyan]6.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('7.'):
                        formatted_lines.append(f"  [cyan]7.[/cyan] {line.strip()[2:].strip()}")

                    else:
                        formatted_lines.append(line)

            # Print the processed content
            if not in_code_block:
                console.print("\n".join(formatted_lines))
            else:
                code_block_content = "\n".join(formatted_lines)
                syntax = Syntax(code_block_content, "bash", theme="monokai", line_numbers=False)
                console.print(Panel(syntax, title="Code Example", border_style="dim"))


# MAIN FUNCTION
def main(prompt=None):

    print("㉿ KaliGPT (Mistral)  - by SudoHopeX|Krishna Dwivedi\n")
    print("㉿ KaliGPT: CyberSecurity Assistant")

    while True:
        try:
            if prompt:
                user_input = prompt
            else:
                user_input = input("Prompt: ")

            if user_input.lower() in ("exit", "quit", "q"):
                break

            reply = ask_ollama(user_input).strip()
            print(f"㉿ KaliGPT: ")
            parse_n_print_response(reply)
            prompt = None

        except KeyboardInterrupt:
            print("\nExiting KaliGPT.")
            break

        except Exception as e:
            print(f"Error: {e}")
            break


if __name__ == "__main__":
    if len(sys.argv) > 1:
        args = ' '.join(sys.argv[1:])
        main(args)
    else:
        main()
PYCODE

		deactivate
		;;

	llama)
		echo "Installing KaliGPT (Llama)"
                echo ""
                start_spinner "Installing Ollama llama AI"
                curl -fsSL https://ollama.com/install.sh | sh
                ollama pull llama3 # or codellama
                stop_spinner "Ollama llama AI Installation"

                echo ""
                start_spinner "pip requirements Installing"
                pip3 install requests rich> /dev/null 2>&1
                stop_spinner "pip Requirements Installation"

                sudo tee kaligpt_llama.py > /dev/null <<'PYCODE'
#!/usr/bin/env python3

# kaligpt_llama.py
import sys
import requests
from rich.console import Console
from rich.text import Text
from rich.panel import Panel
from rich.syntax import Syntax
import re
import os

MODEL = "llama3"
OLLAMA_API_URL = f"http://localhost:11434/api/generate"

def ask(prompt):
    user_prompt = f"""
You are a professional assistant (named 'HopeX') for Linux users, cybersecurity researchers, bug bounty hunters, and ethical hackers.
You are specialized in Kali Linux tools, penetration testing, Bug Bounty Hunting, CTFs, and Linux system administration.
Respond with expert-level detail, real examples, and CLI commands when appropriate. Focus on practical use.

and explain:

{prompt}"""
    r = requests.post("OLLAMA_API_URL,
                      json={"model": MODEL, "prompt": user_prompt, "stream": False})
    return r.json().get("response", "Error")

def get_terminal_size():
    # Get the current terminal size
    try:
        # This works on most operating systems
        terminal_size = os.get_terminal_size()
        console_width = terminal_size.columns
    except OSError:
        # Fallback if unable to determine terminal size
        console_width = 101

    return console_width

def parse_n_print_response(api_response_text):

    # Initialize the rich Console
    console = Console(width=get_terminal_size())

    # Split the response into sections based on markdown headings
    sections = re.split(r'### (.+?)\n|#### (.+?)\n', api_response_text)
    sections = [s for s in sections if s and not s.isspace()]  # Remove empty entries

    # Iterate through sections and print with enhanced formatting
    for section in sections:
        # Check for main headings (e.g., "Hello, Explain Ethical Hacking!")
        if section.startswith('**'):
            title = section.replace('**', '').strip()
            console.print(f"\n[bold green]{title}[/bold green]\n", style="italic")
        # Check for subheadings (e.g., "Key Concepts and Principles:")
        elif section.startswith('**'):
            title = section.replace('**', '').strip()
            console.print(f"\n[bold blue]{title}[/bold blue]\n")
        else:
            # Split the content by lines
            lines = section.strip().split('\n')

            # Process each line for special formatting
            formatted_lines = []
            in_code_block = False

            for line in lines:
                # Handle code blocks
                if line.strip() == '```bash':
                    in_code_block = True
                    continue
                elif line.strip() == '```':
                    in_code_block = False
                    continue

                if in_code_block:
                    formatted_lines.append(line)
                else:
                    # Replace markdown bold and italic with rich styles
                    line = re.sub(r'\*\*(.+?)\*\*', '[bold]\\1[/bold]', line)
                    line = re.sub(r'\*(.+?)\*', '[italic]\\1[/italic]', line)
                    line = re.sub(r'`([^`]+)`', '[purple]\\1[/purple]', line)  # Highlight inline code

                    # Check for bullet points
                    if line.strip().startswith('*'):
                        formatted_lines.append(f"  [yellow]•[/yellow] {line.strip()[1:].strip()}")
                    elif line.strip().startswith('1.'):
                        formatted_lines.append(f"  [cyan]1.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('2.'):
                        formatted_lines.append(f"  [cyan]2.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('3.'):
                        formatted_lines.append(f"  [cyan]3.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('4.'):
                        formatted_lines.append(f"  [cyan]4.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('5.'):
                        formatted_lines.append(f"  [cyan]5.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('6.'):
                        formatted_lines.append(f"  [cyan]6.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('7.'):
                        formatted_lines.append(f"  [cyan]7.[/cyan] {line.strip()[2:].strip()}")

                    else:
                        formatted_lines.append(line)

            # Print the processed content
            if not in_code_block:
                console.print("\n".join(formatted_lines))
            else:
                code_block_content = "\n".join(formatted_lines)
                syntax = Syntax(code_block_content, "bash", theme="monokai", line_numbers=False)
                console.print(Panel(syntax, title="Code Example", border_style="dim"))

def main(prompt=None):
    print("㉿ KaliGPT (llama3)  - by SudoHopeX|Krishna Dwivedi\n")
    print("㉿ KaliGPT: CyberSecurity Assistant")

    while True:
        try:
           if prompt:
                user_input = prompt
           else:
                user_input = input("Enter Prompt: ")

           if user_input.lower() in ("exit", "quit", "q"): break

           print("㉿ KaliGPT:")
           parse_n_print_response(ask(user_input).strip())
           prompt = None

        except KeyboardInterrupt:
            print("\nExiting KaliGPT.")
            break

        except Exception as e:
            print(f"Error: {e}")
            break

if __name__ == "__main__":
    if len(sys.argv) > 1:
        args = ' '.join(sys.argv[1:])
        main(args)
    else:
        main()
PYCODE

		deactivate
		;;

	kaligpt-web)
		echo "KaliGPT-web (OpenAI, Free, Online)"
		echo ""
		echo "[!] It uses Chromium as web brower br default"
		echo "[!] To change it to different browser, follow below steps:"
	        echo "        1. edit '/usr/local/bin/kaligpt' with sudo priviledge"
		echo "        2. find -cw within case ( aprrox at line )"
	        echo "        3. comment chromium line and uncomment or add your preferred browser-command line"
		deactivate
		;;

	gemini)
		echo "Installing KaliGPT ( Gemini = Gemini API required!)"

    # asking for Gemini API Key to install Gemini 2.5 flash
    echo ""
    echo -e "\e[31mEnter Gemini API Key to Install KaliGPT...\e[0m"
    echo -e "\e[33mIf not created one yet then,\e[0m"
    echo -e "\e[33m1. SignIn/Login to Google AI Studio & visit: https://aistudio.google.com/app/apikey\e[0m"
    echo -e "\e[33m2. Click “Create API key”\e[0m"
    echo -e "\e[33m3. Copy and save the key somewhere secure and enter below\e[0m"
    # echo -e "\e[1;31mNOTE: You must have a paid plan to use Gemini API key!\e[0m"
    read -p "Enter your Gemini API Key:" GEMINI_API_KEY

    if [[ -n "$USER_KEY" ]]; then
        sed -i "s|GEMINI_API_KEY = None|GEMINI_API_KEY = \"${GEMINI_API_KEY}\"|" kconfig.py
        echo "[*] Gemini API Key saved to kconfig"
    else
        echo -e "\e[1;31m[!] No API Key entered. You can edit /opt/KaliGPT/kconfig.py to add it.\e[0m"
    fi

    start_spinner "pip requirements Installing"
    pip3 install -U google-genai rich> /dev/null 2>&1
    stop_spinner "pip Requirements Installation"

		sudo tee kaligpt_gemini.py > /dev/null <<'PYCODE'

#!/usr/bin/env python3

from google import genai
from google.genai import types
import sys
from rich.console import Console
from rich.text import Text
from rich.panel import Panel
from rich.syntax import Syntax
import re
import os
import kconfig

client = genai.Client(api_key=kconfig.GEMINI_API_KEY)

def get_gemini_response(input_text):
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=f"""
You are a professional assistant (named 'HopeX') for Linux users, cybersecurity researchers, bug bounty hunters, and ethical hackers.
You are specialized in Kali Linux tools, penetration testing, Bug Bounty Hunting, CTFs, and Linux system administration.
Respond with expert-level detail, real examples, and CLI commands when appropriate. Focus on practical use.

and explain:

{input_text}""",
        config=types.GenerateContentConfig(
            thinking_config=types.ThinkingConfig(thinking_budget=0) # Enable-Disable thinking
        )
    )

    return response.text

def get_terminal_size():
    # Get the current terminal size
    try:
        # This works on most operating systems
        terminal_size = os.get_terminal_size()
        console_width = terminal_size.columns
    except OSError:
        # Fallback if unable to determine terminal size
        console_width = 101

    return console_width

def parse_n_print_response(api_response_text):

    # Initialize the rich Console
    console = Console(width=get_terminal_size())

    # Split the response into sections based on markdown headings
    sections = re.split(r'### (.+?)\n|#### (.+?)\n', api_response_text)
    sections = [s for s in sections if s and not s.isspace()]  # Remove empty entries

    # Iterate through sections and print with enhanced formatting
    for section in sections:
        # Check for main headings (e.g., "Hello, Explain Ethical Hacking!")
        if section.startswith('**'):
            title = section.replace('**', '').strip()
            console.print(f"\n[bold green]{title}[/bold green]\n", style="italic")
        # Check for subheadings (e.g., "Key Concepts and Principles:")
        elif section.startswith('**'):
            title = section.replace('**', '').strip()
            console.print(f"\n[bold blue]{title}[/bold blue]\n")
        else:
            # Split the content by lines
            lines = section.strip().split('\n')

            # Process each line for special formatting
            formatted_lines = []
            in_code_block = False

            for line in lines:
                # Handle code blocks
                if line.strip() == '```bash':
                    in_code_block = True
                    continue
                elif line.strip() == '```':
                    in_code_block = False
                    continue

                if in_code_block:
                    formatted_lines.append(line)
                else:
                    # Replace markdown bold and italic with rich styles
                    line = re.sub(r'\*\*(.+?)\*\*', '[bold]\\1[/bold]', line)
                    line = re.sub(r'\*(.+?)\*', '[italic]\\1[/italic]', line)
                    line = re.sub(r'`([^`]+)`', '[purple]\\1[/purple]', line)  # Highlight inline code

                    # Check for bullet points
                    if line.strip().startswith('*'):
                        formatted_lines.append(f"  [yellow]•[/yellow] {line.strip()[1:].strip()}")
                    elif line.strip().startswith('1.'):
                        formatted_lines.append(f"  [cyan]1.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('2.'):
                        formatted_lines.append(f"  [cyan]2.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('3.'):
                        formatted_lines.append(f"  [cyan]3.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('4.'):
                        formatted_lines.append(f"  [cyan]4.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('5.'):
                        formatted_lines.append(f"  [cyan]5.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('6.'):
                        formatted_lines.append(f"  [cyan]6.[/cyan] {line.strip()[2:].strip()}")
                    elif line.strip().startswith('7.'):
                        formatted_lines.append(f"  [cyan]7.[/cyan] {line.strip()[2:].strip()}")

                    else:
                        formatted_lines.append(line)

            # Print the processed content
            if not in_code_block:
                console.print("\n".join(formatted_lines))
            else:
                code_block_content = "\n".join(formatted_lines)
                syntax = Syntax(code_block_content, "bash", theme="monokai", line_numbers=False)
                console.print(Panel(syntax, title="Code Example", border_style="dim"))


def main(prompt=None):
    print("㉿ KaliGPT (Gemini-2.5 Flash) - by SudoHopeX|Krishna Dwivedi")
    print("㉿ KaliGPT: CyberSecurity Assistant")

    while True:
        try:
            if prompt is None:
                prompt = input("\nYou: ")

            if prompt.lower() in ['exit', 'quit', 'q']:
                print("Exiting KaliGPT. Goodbye!")
                break

            gemini_response = get_gemini_response(prompt)
            print(f"\nKaliGPT:")
            parse_n_print_response(gemini_response)
            prompt = None  # Reset prompt for next iteration
            print('-' * 30)

        except KeyboardInterrupt:
            print("\nExiting KaliGPT. Goodbye!")
            break

if __name__ == "__main__":
    if len(sys.argv) > 1:
        args = ' '.join(sys.argv[1:])
        main(args)
    else:
        main()
PYCODE
		deactivate
		;;

	*)
		echo "[!] Invalid INSTALL_MODE: $INSTALL_MODE"
		deactivate
        	exit 0
        	;;
esac


# kaliGPT Binary path
BIN_PATH="/usr/local/bin/kaligpt"

# Create launcher
echo ""
echo  -e "\e[34m[*] Creating launcher...\e[0m"
sudo tee "$BIN_PATH" > /dev/null <<'EOF'
#!/bin/bash

source /opt/KaliGPT/bin/activate
cd /opt/KaliGPT/

function check_model_installation(){
  local file="$1"

  if [[ -f "$file" ]]; then
    return 0    # success — file exists
  else
    return 1    # failure — file missing
  fi
}

MODE="$1"
shift

case "$MODE" in
	-c|--chatgpt)

	  if ! check_model_installation "kaligpt_chatgpt4o.py"; then
      echo "Please install the KaliGPT ChatGPT-4o model first." >&2
      exit 1
    fi

		python3 kaligpt_chatgpt4o.py "$@"
		;;

	-g|--gemini)

	  if ! check_model_installation "kaligpt_gemini.py"; then
      echo "Please install the KaliGPT Gemini model first." >&2
      exit 1
    fi

		python3 kaligpt_gemini.py "$@"
		;;

	-cw|--chatgpt-web)

	  echo -e "\e[1;32mKaliGPT v1.1 - Use AI in Linux via CLI easily\e[0m"
		echo -e "\e[1;32m             - by SudoHopeX | Krishna Dwivedi\e[0m"
		echo ""
		echo -e "\e[1;33mOpening KaliGPT in Web Browser...\e[0m"
		echo ""
		KALIGPT_LINK="https://chatgpt.com/g/g-xouSQobsE-kaligpt"
		# to use chromium web browser [default] [ comment or uncomment just below line only]
    chromium "$KALIGPT_LINK"

    # to use firefox web browser [ comment or uncomment this below line only ]
    # firefox "$KALIGPT_LINK"

    # to use google chrome web browser [ comment or uncomment this below line only ]
    # google-chrome "$KALIGPT_LINK"

    # to use device default web browser [ comment or uncomment this below line only ]
    # xdg-open "$KALIGPT_LINK"

    # to use something else, find its command and replace it by <browser-cmd> in below line & uncomment it only ]
    # <browser-command> "$KALIGPT_LINK"
		;;

	-m|--mistral)

	  if ! check_model_installation "kaligpt_mistral.py"; then
      echo "Please install the KaliGPT mistral model first." >&2
      exit 1
    fi

		if ! pgrep -f "ollama serve" > /dev/null; then
    			nohup ollama serve > /var/log/ollama.log 2>&1 &
    			sleep 2
		fi
		python3 kaligpt_mistral.py"$@"
		;;

	-l|--llama)

	  if ! check_model_installation "kaligpt_llama.py"; then
      echo "Please install the KaliGPT llama model first." >&2
      exit 1
    fi

		if ! pgrep -f "ollama serve" > /dev/null; then
    			nohup ollama serve > /var/log/ollama.log 2>&1 &
    			sleep 2
		fi

		python3 kaligpt_llama.py"$@"
		;;

	-h|--help)
		echo ""
		echo -e "\e[1;32mKaliGPT v1.1 - Use AI in Linux via CLI easily\e[0m"
		echo -e "\e[1;32m             - by SudoHopeX | Krishna Dwivedi\e[0m"
		echo ""
		echo -e "\e[1;33mUsages:\e[0m"
		echo " 	kaligpt [MODE] [FLAG(Optional)] [Prompt (optional)]"
		echo ""
		echo -e "\e[1;33mMODES: (Must Included)\e[0m"
		echo ""
		echo "    -c  [--chatgpt]           =  use ChatGPT-4o (Online)"
		echo "    -cw [--chatgpt-web]       =  use KaliGPT in Web Browser (Online)"
		echo "		    ( requires 1 time login & keep logged in configs on web )"
		echo "    -g  [--gemini]            =  use Gemini 2.5 Flash (Online)"
		echo "    -m  [--mistral]           =  use Mistral via Ollama (Offline)"
		echo "    -l  [--llama]             =  use LlaMa via Ollama (Offline)"
		echo "    -i  [--install]           = install a model bu using --model <model-num>"
		echo "    -lm [--list-models]       = list KaliGPT available models"
		echo "    -u  [--uninstall]         = uninstall a model or KaliGPT (everything)"
		echo ""
		echo -e "\e[1;33mFLAGS:\e[0m"
		echo "    --model <model-num>        = specify a model to install (with --install)"
		echo "    --uninstall-m <model-num>  =  uninstall a specific model (with --uninstall)"
    echo "    --uninstall-k              =  uninstall KaliGPT (everything) (with --uninstall)"
		echo "    -h [--help]                =  show this help message and exit"
		echo ""
		echo -e "\e[1;33mExamples:\e[0m"
		echo "     kaligpt -g \"How to Scan a website for subdomains using tools\""
		echo "     kaligpt -l \"Help me find XXS on a target.com\""
		echo "     kaligpt --install --model 5"
		echo "     kaligpt -u --uninstall-m 1"
		echo "     kaligpt -cw"
		echo ""
		echo -e "\e[31m NOTE: do not pass prompt with -cw\e[0m"
		echo -e "\e[33m       Must include a MODE & use flags only with specified mode"
		echo -e "\e[33m       Read README.md or Documentation at sudohopex.github.io for more info.\e[0m"
		;;

  -i|--install)
     # Install a model using kaligpt itself instead of using installer only
     sudo bash kaligpt_unified.sh "$@"
     ;;

  -lm|--list-models)
    echo -e "\e[1;33mKaliGPT MODELs:\e[0m"
    echo "   1) OpenAI ChatGPT ( OpenAI, Free, Online ) [ Requires API KEY ]"
    echo "   2) Mistral    ( Free, Offline - Min 6GB Data Required)"
    echo "   3) Llama      ( Free, Offline )"
    echo "   4) KaliGPT -web based ( OpenAI, Free, Online )"
    echo "   5) Gemini-2.5 Flash (Google, Free, Online) [ Requires API Key ]"
    echo ""
    echo "      [Note: opttion 4 required 1 time logging & keep logged in config in chromium if not]"
    ;;

  -u|--uninstall)
    sudo bash kaligpt_unified.sh "$@"
    ;;

	*)
		echo -e "\e[1;31mNOTE: Invalid or missing mode!\e[0m"
		echo -e "\e[1;33muse: kaligpt -h to see usages\e[0m"
		exit 1
		;;
esac

deactivate
EOF

# Make launcher executable
sudo chmod +x "$BIN_PATH"

echo ""
echo ""
echo  -e "\e[1;32m Kali Linux + Kali GPT = Hack everything (Ethically) ~ SudoHopeX\e[0m"
echo  -e "\e[1;32mUse KaliGPT via command: 'kaligpt -h' to see uses\e[0m"
