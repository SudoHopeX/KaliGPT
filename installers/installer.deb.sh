# !/bin/bash
trap "kill $SPIN_PID 2>/dev/null" EXIT
USER_NAME=$(logname 2>/dev/null)

# KaliGPT v1.3 Setup (check & install dependencies, create launcher) Script for Debian-based Systems
# by SudoHopeX ( https://github.com/SudoHopeX )
# Last Modified: 8 fEB 2026


# Ensure script runs as root, prompt for sudo if needed
if [ "$EUID" -ne 0 ]; then
    echo ""
    echo -e "\e[1;31mError: This script requires root privileges.\e[0m" >&2
    echo -e "\e[1;33mRequesting sudo privileges... (if it get's sudo privileges automatically it may be due to sudo's credential caching mechanism)\e[0m"
    exec sudo bash "$0" "$@"
fi


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
    for pkg in "$@"; do
      if ! dpkg -s "$pkg" >/dev/null 2>&1; then
          start_spinner "$pkg Installing..."
          apt-get install "$pkg" -y > /dev/null 2>&1
          stop_spinner "$pkg Installation"
      else
          echo -e "\r\e[1;32m[✓] $pkg is already installed.\e[0m"
      fi
    done
}


# ---- performing system update ----
echo ""
start_spinner "System Updating"
apt update > /dev/null 2>&1
stop_spinner "System Update"


# ---- checking and installing missing pkgs for KaliGPT & OpenSearchAPI -----
echo ""
install_if_missing python3 python3-pip python3-venv chromium xvfb


# ---- creating KaliGPT installation directory  ----
mkdir -p /opt/KaliGPT/

# ----- KaliGPT v1.3 (HackerX) Source Cloning -----
echo ""
start_spinner "Cloning KaliGPT repository"
git clone https://github.com/SudoHopeX/KaliGPT.git /opt/KaliGPT/ > /dev/null 2>&1
stop_spinner "KaliGPT Repository Clone"

# ----- Creating OpenSearchAPI Install Dir & Cloning OpenSearchAPI source -----
mkdir -p /opt/KaliGPT/OpenSearchAPI/
start_spinner "Cloning OpenSearchAPI repository"
git clone https://github.com/SudoHopeX/OpenSearchAPI.git /opt/KaliGPT/OpenSearchAPI/ > /dev/null 2>&1
stop_spinner "OpenSearchAPI repository clone"


# ----- Installing Ollama and pulling model (if user wants) -----
echo "" # Clean line
read -p "Wanna install Ollama (to use local AI models) ? (y/N): " install_ollama
# install_ollama=${install_ollama:-N}     # default to N (No)
if [[ "$install_ollama" =~ ^[Yy]$ ]]; then
    echo -e "\e[1;32mProceeding with Ollama installation...\e[0m"

    start_spinner "Installing Ollama"
    curl -fsSL https://ollama.com/install.sh | sh > /dev/null 2>&1
    stop_spinner "Ollama Installation"

    read -p "Enter Ollama model to install (default: llama3): " ollama_model
    ollama_model=${ollama_model:-qwen3:8b} # default to qwen3:8b if no input

    # FIX: Do not use start_spinner here so we can see Ollama own installation progress bar
    echo -e "\e[1;32m[+] Pulling Ollama model: $ollama_model (this may take a while)...\e[0m"
    ollama pull "$ollama_model"
    echo -e "\e[1;32m[✓] Ollama model $ollama_model pull complete!\e[0m"

else
    echo -e "\e[33mOllama AI models installation skipped by user.\e[0m"
fi

# ----- Setting up KaliGPT Virtual Environment & installing python requirements -----
python3 -m venv /opt/KaliGPT/its_venv
source /opt/KaliGPT/its_venv/bin/activate
cd /opt/KaliGPT/

echo ""
start_spinner "pip requirements Installing"
pip3 install -r requirements/pip-requirements.txt > /dev/null 2>&1
stop_spinner "pip Requirements Installation"


# ----- API KEY configuration setup -----  ( if N skip, else start setup )
echo "" # clear the line
read -p "Do you want to set up API keys now? (Y/n): " setup_api
setup_api=${setup_api:-Y}     # default to Y (Yes) if no input is read
if [[ "$setup_api" =~ ^[Nn]$ ]]; then
    echo -e "\e[33mAPI key setup skipped by user. You can set up API keys later using \e[0m\e[1;32mkaligpt --setup-keys\e[0m."
else
    echo -e "\e[1;32mProceeding with API key setup...\e[0m"
    python3 -m agents --setup-keys
fi

deactivate  # deactivate venv


# ----- LAUNCHER CREATION -----
LAUNCHER_BIN_PATH="/usr/local/bin/kaligpt"

# Create launcher
echo ""
start_spinner "Creating KaliGPT launcher at $LAUNCHER_BIN_PATH"
tee "$LAUNCHER_BIN_PATH" > /dev/null <<'EOF'
#!/bin/bash

# KaliGPT v1.3 Launcher Script
# by SudoHopeX ( https://github.com/SudoHopeX )

source /opt/KaliGPT/its_venv/bin/activate
cd /opt/KaliGPT
OpenSearchAPI_PID=""  # Initialize for holding OpenSearchAPI PID

# start the OpenSearchAPI server in background
st_opensearchapi() {
  OpenSearchAPI_PID=$(opensearchapi --bg)
}

MODE="$1"
shift

case "$MODE" in

        -g|--gemini)
                st_opensearchapi
                python3 -m agents.gemini "$@"
                ;;

        -o|--ollama)
                st_opensearchapi
                python3 -m agents.ollama "$@"
                ;;

        -or|--openrouter)
                st_opensearchapi
                python3 -m agents.openrouter "$@"
                ;;

        -rq|--requesty)
                st_opensearchapi
                python3 -m agents.requesty "$@"
                ;;

        -c|--chatgpt)
                st_opensearchapi
                python3 -m agents.chatgpt "$@"
                ;;

        --web)
                python3 -m agents.web_launcher "$@"
                ;;

        -h|--help)
                echo ""
                echo -e "\e[1;32mKaliGPT v1.3 - Use AI in Linux via CLI easily\e[0m"
                echo -e "\e[1;32m             - by SudoHopeX\e[0m"
                echo ""
                echo -e "\e[1;33mUsages:\e[0m"
                echo "         kaligpt [MODE] [Prompt]"
                echo ""
                echo -e "\e[1;33mMODES: \e[0m"
                echo ""
                echo "    -g  [--gemini]            =  use Gemini Models (Online, text & code)"
                echo "    -o  [--ollama]            =  use Ollama Models (Offline, text & code)"
                echo "    -or [--openrouter]        =  use OpenRouter Models (Online, text & code)"
                echo "    -rq [--requesty]          =  use Requesty Models (Online, text & code)"
                echo "    -c  [--chatgpt]           =  use OpenAI Models (Online, text & code)"
                echo "    --web                     =  AIs official Web-Chat Opener (Online)"
                echo "    --setup-keys              =  setup API keys for online models"
                echo "    -u [--update]             =  update KaliGPT to latest version"
                echo "    -v [--version]            =  show KaliGPT version and exit"
                echo "    -lr [--list-providers]    = list KaliGPT available models"
                echo "    -h [--help]               =  show this help message and exit"
                echo ""
                echo -e "\e[1;33mModel Management: \e[0m"
                echo ""
                echo "    /change-model             = change to a different AI model"
                echo "    /reset-to-default-model   = reset to KaliGPT default AI model (Gemini)"
                echo "    /list-tools               = list available tools for AI Agent"
                echo ""
                echo -e "\e[1;33mExamples:\e[0m"
                echo "     kaligpt  ( uses default model and will ask for prompt )"
                echo "     kaligpt \"Help me find XSS on target.com\""
                echo "     kaligpt -or \"Write a python script to automate port scanning using nmap\""
                echo "     kaligpt --web  (launches default AI model's web chat)"
                echo ""
                echo -e "\e[33m       Read README.md or Docs at https://hope.is-a.dev?path=kaligpt for more info.\e[0m"
                ;;

       -u|--update)
                # Check for updates
                echo -e "\e[1;33mChecking for updates...\e[0m"
                git fetch origin hackerx
                LOCAL=$(git rev-parse HEAD)
                REMOTE=$(git rev-parse origin/hackerx)

                if [ "$LOCAL" != "$REMOTE" ]; then
                    echo -e "\e[1;32mNew version found! Updating KaliGPT...\e[0m"
                    if git pull origin hackerx > /dev/null 2>&1; then
                        bash installers/installer.deb.sh
                        echo -e "\e[1;32mKaliGPT has been updated to the latest version!\e[0m"
                    else
                        echo -e "\e[1;31mUpdate failed! Could not pull the latest changes.\e[0m"
                        exit 1
                    fi
                else
                    echo -e "\e[1;32mKaliGPT is already up-to-date.\e[0m"
                fi
                ;;

        -lr|--list-providers)
                echo -e "\e[1;33mKaliGPT Provides:\e[0m
                1) Google Gemini Models  ( Free/Paid, Online) [ Requires API Key ]
                2) OpenRouter Models     (Various, Free/Paid, Online) [ Requires API Key ]
                3) Ollama                (Free, Offline) [ Local AI Models ]
                4) OpenAI ChatGPT        (Paid, Online)  [Required API Key]
                "
                ;;

        -v|--version)
                # printing version info from git tags
                git describe --tags
                # echo "HackerX (KaliGPT v1.3.0)"
                ;;

        --setup-keys)
                python3 -m agents "$MODE"
                ;;

         *)
                st_opensearchapi
                # Passing "$MODE" first ensures the first word is not lost if it was a prompt
                python3 -m agents "$MODE" "$@"
                ;;

esac

# Stop OpenSearchAPI server via kill PID
if [ -n "$OpenSearchAPI_PID" ]; then
  kill "$OpenSearchAPI_PID" > /dev/null 2>&1
fi

# Deactivate venv after execution
deactivate
EOF

# Make KaliGPT launcher executable
chmod +x "$LAUNCHER_BIN_PATH"
stop_spinner "KaliGPT launcher creation"


# Create a simple launcher for starting OpenSearchAPI & give executable permissions
tee /usr/local/bin/opensearchapi > /dev/null <<'EOF'
#!/usr/bin/env bash

# echo "SudoHopeX - OpenSearchAPI"

source /opt/KaliGPT/its_venv/bin/activate

if [ "$1" == "--bg" ]; then
  python /opt/KaliGPT/OpenSearchAPI/app.py > /dev/null 2>&1 &
  APP_ID=$!
  echo "$APP_ID"
else
  python /opt/KaliGPT/OpenSearchAPI/app.py
  APP_ID=$!
  echo "OpenSearchAPI Started with PID: $APP_ID"
fi

deactivate
EOF

chmod +x /usr/local/bin/opensearchapi

# ----- Change ownership of /opt/KaliGPT/ from root to the actual user who ran sudo -----
chown -R "$USER_NAME":"$USER_NAME" /opt/KaliGPT/
chmod 666 /opt/KaliGPT/agents/utils/api.config.json

# ----- Final Message -----
echo -e "\e[1;32mKaliGPT v1.3 (HackerX) installed Successfully!\e[0m"
echo -e "\e[1;33mYou can run KaliGPT using the command: \e[0m\e[1;32mkaligpt\e[0m"

# ----- Test run KaliGPT with help flag -----
echo ""
kaligpt --help
