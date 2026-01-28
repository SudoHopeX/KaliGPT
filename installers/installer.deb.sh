# !/bin/bash
trap "kill $SPIN_PID 2>/dev/null" EXIT
USER_NAME=$(logname 2>/dev/null)

# KaliGPT v1.3 Setup (check & install dependencies, create launcher) Script for Debian-based Systems
# by SudoHopeX ( https://github.com/SudoHopeX )
# Last Modified: 28 Jan 2026


# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo -e "\e[1;31mPlease run as root (switch to superuser 'root' - use 'sudo su' or 'su root'\e[0m"
  exit 1
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
sudo apt update > /dev/null 2>&1
stop_spinner "System Update"


# ---- checking and installing missing pkgs  -----
echo ""
install_if_missing python3 python3-pip python3-venv golang-go


# ---- creating KaliGPT installation directory  ----
mkdir -p /opt/KaliGPT/

# ----- KaliGPT v1.3 (HackerX) Source Cloning -----
echo ""
start_spinner "Cloning KaliGPT repository"
git clone --branch hackerx --single-branch https://github.com/SudoHopeX/KaliGPT.git /opt/KaliGPT/ > /dev/null 2>&1
stop_spinner "KaliGPT Repository Clone"

# ----- Cloning and building OpenSerp binary -----
start_spinner "Cloning OpenSerp repository"
git clone https://github.com/karust/openserp.git /opt/KaliGPT/openserp/ > /dev/null 2>&1
stop_spinner "OpenSerp repository clone"

start_spinner "Building OpenSerp binary"
# FIX: Change directory to build the actual source
cd /opt/KaliGPT/openserp/ && go build -o openserp . > /dev/null 2>&1
cd - > /dev/null # Go back to previous directory
stop_spinner "OpenSerp binary build"

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
    ollama_model=${ollama_model:-llama3} # default to llama3 if no input

    # FIX: Do not use start_spinner here so we can see Ollama own installation progress bar
    echo -e "\e[1;32m[+] Pulling Ollama model: $ollama_model (this may take a while)...\e[0m"
    ollama pull "$ollama_model"
    echo -e "\e[1;32m[✓] Ollama model $ollama_model pull complete!\e[0m"

else
    echo -e "\e[33mOllama AI models installation skipped by user.\e[0m"
fi

# ----- Setting up KaliGPT Virtual Environment & installing python requirements -----
sudo python3 -m venv /opt/KaliGPT/kaligpt_venv
source /opt/KaliGPT/kaligpt_venv/bin/activate
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
sudo tee "$LAUNCHER_BIN_PATH" > /dev/null <<'EOF'
#!/bin/bash

# KaliGPT v1.3 Launcher Script
# by SudoHopeX ( https://github.com/SudoHopeX )

source /opt/KaliGPT/kaligpt_venv/bin/activate
cd /opt/KaliGPT

# start the openserp server in background
start_openserp() {
    cd /opt/KaliGPT/openserp/
    nohup ./openserp serve > /dev/null 2>&1 &
    cd /opt/KaliGPT
}

MODE="$1"
shift

case "$MODE" in

        -g|--gemini)
                start_openserp
                python3 -m agents.gemini "$@"
                ;;

        -o|--ollama)
                start_openserp
                python3 -m agents.ollama "$@"
                ;;

        -or|--openrouter)
                start_openserp
                python3 -m agents.openrouter "$@"
                ;;

        -c|--chatgpt)
                start_openserp
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
                echo "         kaligpt [MODE(Optional)] [Prompt (optional)]"
                echo ""
                echo -e "\e[1;33mMODES: \e[0m"
                echo ""
                echo "    -g  [--gemini]            =  use Gemini Models (Online, text & code)"
                echo "    -o  [--ollama]            =  use Ollama Models (Offline, text & code)"
                echo "    -or [--openrouter]        =  use OpenRouter Models (Online, text & code)"
                echo "    -c  [--chatgpt]           =  use OpenAI Models (Online, text & code)"
                echo "    --web                     =  AIs official Web-Chat Opener (Online)"
                echo "    --setup-keys              =  setup API keys for online models"
                echo "    -u [--update]             =  update KaliGPT to latest version"
                echo "    -v [--version]            =  show KaliGPT version and exit"
                echo "    -lr [--list-providers]    = list KaliGPT available models"
                echo "    -h [--help]               =  show this help message and exit"
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
                # Check for updated
                echo -e "\e[1;33mChecking for updates...\e[0m"
                git fetch origin hackerx
                LOCAL=$(git rev-parse HEAD)
                REMOTE=$(git rev-parse origin/hackerx)
                if [ $LOCAL != $REMOTE ]; then
                    echo -e "\e[1;32mNew version found! Updating KaliGPT...\e[0m"
                    git pull origin hackerx > /dev/null 2>&1
                    sudo bash installers/installer.deb.sh > /dev/null 2>&1
                    echo -e "\e[1;32mKaliGPT has been updated to the latest version!\e[0m"
                else
                    echo -e "\e[1;32mKaliGPT is already up-to-date.\e[0m"
                fi
                ;;

        -lr|--list-providers)
                echo -e "\e[1;33mKaliGPT Provides:\e[0m
                1) Google Gemini Models  ( Free/Paid, Online) [ Requires API Key ]
                2) OpenRouter Models (Various, Free/Paid, Online) [ Requires API Key ]
                3) Ollama            (Free, Offline) [ Local AI Models ]
                "
                ;;

        -v|--version)
                # printing version info from git tags
                # git describe --tags
                echo "HackerX (KaliGPT v1.3)"
                ;;

        --setup-keys)
                python3 -m agents "$MODE"
                ;;

         *)
                start_openserp
                # Passing "$MODE" first ensures the first word is not lost if it was a prompt
                python3 -m agents "$MODE" "$@"
                ;;

esac
deactivate
EOF

# Make launcher executable
sudo chmod +x "$LAUNCHER_BIN_PATH"
stop_spinner "KaliGPT launcher creation"

# Change ownership from root to the actual user who ran sudo
chown -R "$USER_NAME":"$USER_NAME" /opt/KaliGPT/

# Final Message
echo -e "\e[1;32mKaliGPT v1.3 (HackerX) installed Successfully!\e[0m"
echo -e "\e[1;33mYou can run KaliGPT using the command: \e[0m\e[1;32mkaligpt\e[0m"

# test run with help flag
echo ""
kaligpt --help
