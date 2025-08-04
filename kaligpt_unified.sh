#!/bin/bash
trap "kill $SPIN_PID 2>/dev/null" EXIT


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
echo -e "\e[1;33mKaliGPT Available MODELs:\e[0m"
echo "   1) OpenAI ChatGPT ( OpenAI, Free, Online ) [ requires API KEY ]"
echo "   2) Mistral    ( Free, Offline - Min 6GB Data Required)"
echo "   3) Llama      ( Free, Offline )"
echo "   4) KaliGPT -web based ( OpenAI, Free, Online )"
echo "      [Note: opttion 4 required 1 time logging & keep logged in config in chromium if not]"
exit 0
}

# print KaliGPT Installer script uses
print_installer_usages() {
  echo -e "\e[1;33mKaliGPT Installer Available commands:\e[0m"
  echo "   --model <model-num>         -  install a specific model"
  echo "   --listmodels                -  list available models"
  echo "   --uninstall-m <model-num>   -  uninstall a specific model"
  echo "   --uninstall                 -  uninstall KaliGPT (everything)"
  echo "   --help                      -  print this usage info"
  echo ""
  print_models
}


# unistall a model
uninstall_model() {
    case "$1" in
        1)
            PY_FILE="/opt/KaliGPT/kaligpt_chatgpt4o.py"
            ;;
        2)
            PY_FILE="/opt/KaliGPT/kaligpt_mistral.py"
            ;;
        3)
            PY_FILE="/opt/KaliGPT/kaligpt_llama.py"
            ;;
        *)
            echo "Invalid uninstall option: $1"
            exit 1
            ;;
    esac

    echo "[*] Removing script: $PY_FILE"
    sudo rm -f "$PY_FILE"

    echo "[✓] Uninstall of model $1 complete."
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
echo  -e "\e[1;32mKaliGPT Installer ~ SudoHopeX | Krishna Dwivedi\e[0m"
echo  -e "\e[1;32m[Contact SudoHopeX](https://sudohopex.github.io/)\e[0m"
echo ""

# argument parser
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --help)
            print_installer_usages
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
            echo "Unknown parameter: $1"
            exit 1
            ;;
    esac
    shift
done


# Execute actions
if [ "$SHOW_MODELS" = true ]; then
    print_models
fi

if [ -n "$UNINSTALL_MODE" ]; then
    uninstall_model "$UNINSTALL_MODE"
fi

if [ -z "$MODEL_CHOICE" ]; then
    echo "No model specified. Use --model 1|2|3"
    echo "Use --list-models to see available options."
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
        *)
                echo "Invalid model selection."; exit 1 ;;
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

                start_spinner "pip requirements Installing"
                pip3 install openai> /dev/null 2>&1
                stop_spinner "pip Requirements Installation"

                cat <<PYCODE > kaligpt_chatgpt4o.py
from openai import OpenAI
import sys

# CONFIGs
client = OpenAI(
      api_key = "$OPENAI_API_KEY"
)

MODEL = "gpt-4o"

# Custom system prompt for professional GPT
SYSTEM_PROMPT = """
You are a professional assistant (named 'SudoHopeX') for Linux users, cybersecurity researchers, bug bounty hunters, and ethical hackers.
You are specialized in Kali Linux tools, penetration testing, Bug Bounty Hunting, CTFs, and Linux system administration.
Respond with expert-level detail, real examples, and CLI commands when appropriate. Focus on practical use.
"""

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

            if user_input.lower() in ("exit", "quit"):
                break

            response = client.responses.create(
                       model=MODEL,
                       instructions=SYSTEM_PROMPT,
                       input=user_input
            )

            reply = response.output_text

            print(f"㉿ KaliGPT: {reply}")

            prompt = None

        except Exception as e:
            print(f"Error: {e}")
            break


if __name__ == "__main__":
   if sys.argv[1:]:
      main(sys.argv[1:])
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
                pip3 install requests> /dev/null 2>&1
                stop_spinner "pip Requirements Installation"

                cat <<PYCODE > kaligpt_mistral.py
import sys
import requests

MODEL = "mistral"  # or llama3, codellama, etc.
OLLAMA_API_URL = f"http://localhost:11434/api/generate"

# Custom system prompt for professional GPT
SYSTEM_PROMPT = """
You are a professional assistant (named 'SudoHopeX') for Linux users, cybersecurity researchers, bug bounty hunters, and ethical hackers.
You are specialized in Kali Linux tools, penetration testing, Bug Bounty Hunting, CTFs, and Linux system administration.
Respond with expert-level detail, real examples, and CLI commands when appropriate. Focus on practical use.
"""

def ask_ollama(prompt):
    payload = {
        "model": MODEL,
        "prompt": f"{SYSTEM_PROMPT}\n\nUser: {prompt}\nAI:",
        "stream": False
    }

    try:
        response = requests.post(OLLAMA_API_URL, json=payload)
        response.raise_for_status()
        return response.json()["response"]

    except Exception as e:
        return f"Error: {e}"

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

            if user_input.lower() in ("exit", "quit"):
                break

            reply = ask_ollama(user_input)
            print(f"㉿ KaliGPT: {reply.strip()}")
            prompt = None

        except KeyboardInterrupt:
            print("\nExiting KaliGPT.")
            break

        except Exception as e:
            print(f"Error: {e}")
            break


if __name__ == "__main__":
   if sys.argv[1:]:
      main(sys.argv[1:])
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
                ollama pull llama3
                stop_spinner "Ollama llama AI Installation"

                echo ""
                start_spinner "pip requirements Installing"
                pip3 install requests> /dev/null 2>&1
                stop_spinner "pip Requirements Installation"

                cat <<PYCODE > kaligpt_llama.py
import sys
import requests

MODEL = "llama3"
OLLAMA_API_URL = f"http://localhost:11434/api/generate"

# Custom system prompt for professional GPT
SYSTEM_PROMPT = """
You are a professional assistant (named 'SudoHopeX') for Linux users, cybersecurity researchers, bug bounty hunters, and ethical hackers.
You are specialized in Kali Linux tools, penetration testing, Bug Bounty Hunting, CTFs, and Linux system administration.
Respond with expert-level detail, real examples, and CLI commands when appropriate. Focus on practical use.
"""

def ask(prompt):
    r = requests.post("OLLAMA_API_URL,
                      json={"model": MODEL, "prompt": f"\n{SYSTEM_PROMPT}\n{prompt}", "stream": False})
    return r.json().get("response", "Error")

def main(prompt=None):
    print("㉿ KaliGPT (llama3)  - by SudoHopeX|Krishna Dwivedi\n")
    print("㉿ KaliGPT: CyberSecurity Assistant")

    while True:
        try:
           if prompt:
                user_input = prompt
           else:
                user_input = input("Enter Prompt: ")

           if user_input.lower() in ("exit", "quit"): break

           print("㉿ KaliGPT:", ask(user_input).strip())
           prompt = None
 
        except KeyboardInterrupt:
            print("\nExiting KaliGPT.")
            break

        except Exception as e:
            print(f"Error: {e}")
            break

if __name__ == "__main__":
   if sys.argv[1:]:
      main(sys.argv[1:])
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
                exit 1
                ;;

        *)
                echo "[!] Invalid INSTALL_MODE: $INSTALL_MODE"
                deactivate
                exit 1
                ;;
esac


# kaliGPT Binary path
BIN_PATH="/usr/local/bin/kaligpt"

# Create launcher
echo ""
echo  -e "\e[34m[*] Creating launcher...\e[0m"
sudo tee "$BIN_PATH" > /dev/null << EOF
#!/bin/bash

source /opt/KaliGPT/bin/activate
cd /opt/KaliGPT/

MODE="\$1"
shift

case "\$MODE" in
        -c)
                python3 kaligpt_chatgpt4o.py"\$@"
                ;;

        -cw)
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
                # <browser-cmd> "$KALIGPT_LINK"
                ;;

        -m)
                if ! pgrep -f "ollama serve" > /dev/null; then
                        nohup ollama serve > /var/log/ollama.log 2>&1 &
                        sleep 2
                fi
                python3 kaligpt_mistral.py"\$@"
                ;;

        -l)
                if ! pgrep -f "ollama serve" > /dev/null; then
                        nohup ollama serve > /var/log/ollama.log 2>&1 &
                        sleep 2
                fi
                python3 kaligpt_mistral.py"\$@"
                ;;

        -h)
                echo ""
                echo -e "\e[1;32mKaliGPT - Use AI in Linux via CLI easily\e[0m"
                echo -e "\e[1;32m        - by SudoHopeX | Krishna Dwivedi\e[0m"
                echo ""
                echo -e "\e[1;33mUsages:\e[0m"
                echo "  kaligpt [mode] [Prompt (optional)]"
                echo ""
                echo -e "\e[1;33mMODES: (Must Included)\e[0m"
                echo "    -c  -  use ChatGPT-4o (OpenAI, Paid, Online)"
                echo "    -cw -  use KaliGPT in chromium web browser (OpenAI, Free, Online )"
                echo "            [ requires 1 time login & keep logged in config on web ]"
                echo "    -m  -  use Mistral via Ollama (Free, Offline)" 
                echo "    -l  -  use LlaMa via Ollama (Free, Offline)"
                echo "    -h  -  show this help message and exit"
                echo ""
                echo -e "\e[1;33mExamples:\e[0m"
                echo "     kaligpt -m \"How to Scan a website for subdomains using tools\""
                echo "     kaligpt -l \"Help me find XXS on a target.com\""
                echo "     kaligpt -c"
                echo "     kaligpt -cw"
                echo ""
                echo -e "\e[31m NOTE: do not pass prompt with -cw\e[0m"
                echo -e "\e[33mRead README.md or Documentation at sudohopex.github.io for more info\e[0m"
                ;;

        *) 
                echo -e "\e[1;31mNOTE: Invalid or missing mode!\e[0m"
                echo -e "\e[1;33mUse: kaligpt -h to see usages\e[0m"
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
