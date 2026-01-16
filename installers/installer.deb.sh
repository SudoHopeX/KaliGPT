# !/bin/bash
trap "kill $SPIN_PID 2>/dev/null" EXIT


# /install.sh for Debian-based Systems
# KaliGPT v1.3 Setup (check & install dependencies, create launcher) Script
# by SudoHopeX ( https://github.com/SudoHopeX )
# Last Modified: 16 Jan 2026


# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo -e "\e[1;31mPlease run as root (use sudo)\e[0m"
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
        local pkg="$1"

        if ! dpkg -s $pkg >/dev/null 2>&1; then

                start_spinner "$pkg Installing..."
                sudo apt-get install $pkg -y > /dev/null 2>&1
                stop_spinner "$pkg Installation"

        else
                echo  -e "\e[33m$pkg Installation found...\e[0m"
        fi
}


start_spinner "System Updating"
sudo apt update > /dev/null 2>&1
stop_spinner "System Update"

# checking and installing missing pkgs
install_if_missing python3
install_if_missing python3-pip
install_if_missing python3-venv
install_if_missing curl
install_if_missing golang-go


# ----- KaliGPT v1.3 (HackerX) Source Cloning -----
start_spinner "Cloning KaliGPT repository"
git clone --branch hackerx --single-branch https://github.com/SudoHopeX/KaliGPT.git /opt/ > /dev/null 2>&1
stop_spinner "KaliGPT repository clone"

# ----- Cloning and setting up OpenSerp -----
start_spinner "Cloning OpenSerp repository"
git clone https://github.com/karust/openserp.git /opt/KaliGPT/ > /dev/null 2>&1
stop_spinner "OpenSerp repository clone"

start_spinner "Building OpenSerp binary"
go build -o /opt/KaliGPT/openserp/openserp . > /dev/null 2>&1
stop_spinner "OpenSerp binary build"

# ----- Installing Ollama and pulling model -----
read -p "Wanna install Ollama (for using AI models locally) ? (y/N): " install_ollama
if [[ "$install_ollama" == "y" && "$install_ollama" == "Y" ]]; then

    echo -e "\e[1;32mProceeding with Ollama installation...\e[0m"

    start_spinner "Installing Ollama"
    curl -fsSL https://ollama.com/install.sh | sh > /dev/null 2>&1
    stop_spinner "Ollama Installation"

    read -p "Enter Ollama model to install (default: llama3): " ollama_model
    ollama_model=${ollama_model:-llama3} # default to llama3 if no input
    start_spinner "Pulling Ollama model: $ollama_model"

    ollama pull "$ollama_model"
    stop_spinner "Ollama model $ollama_model pull"
else
    echo -e "\e[33mOllama AI models installation skipped by user.\e[0m"
fi

# ----- Setting up KaliGPT Virtual Environment & installing python requirements -----
sudo python3 -m venv /opt/KaliGPT/kaligpt_venv
source /opt/KaliGPT/kaligpt_venv/bin/activate

start_spinner "pip requirements Installing"
pip3 install -r /opt/KaliGPT/requirements/pip-requirements.txt > /dev/null 2>&1
stop_spinner "pip Requirements Installation"

# ----- API KEY configuration setup -----  ( if N skip, else start setup )
read -p "Do you want to set up API keys now? (Y/n): " setup_api
if [[ "$setup_api" == "n" || "$setup_api" == "N" ]]; then
    echo -e "\e[33mAPI key setup skipped by user. You can set up API keys later using 'kaligpt --setup-keys'.\e[0m"
else
    echo -e "\e[1;32mProceeding with API key setup...\e[0m"
    python3 /opt/KaliGPT/main.py --setup-keys
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

MODE="$1"
shift

case "$MODE" in

	-g|--gemini)
		python3 -m agents.gemini "$@"
		;;

	-o|--ollama)
    python3 -m agents.ollama "$@"
    ;;

  -or|--openrouter)
    python3 -m agents.openrouter "$@"
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
		echo " 	kaligpt [MODE(Optional)] [Prompt (optional)]"
		echo ""
		echo -e "\e[1;33mMODES: \e[0m"
		echo ""
		echo "    -g  [--gemini]            =  use Gemini Models (Online, text & code)"
    echo "    -o  [--ollama]            =  use Ollama Models (Offline, text & code)"
    echo "    -or [--openrouter]        =  use OpenRouter Models (Online, text & code)"
    echo "    --web                     =  AI's official Web-Chat Opener (Online)"
		echo "    -lr [--list-providers]    = list KaliGPT available models"
		echo "    --setup-keys              =  setup API keys for online models"
		echo "    -u [--update]             =  update KaliGPT to latest version"
		echo "    -v [--version]            =  show KaliGPT version and exit"
		echo "    -h [--help]               =  show this help message and exit"
		echo ""
		echo -e "\e[1;33mExamples:\e[0m"
		echo "     kaligpt -g \"How to Scan a website for subdomains using tools\""
		echo "     kaligpt -or \"Write a python script to automate port scanning using nmap\""
		echo "     kaligpt --web"
		echo ""
		echo -e "\e[33m       Read README.md or Docs at https://hope.is-a.dev?path=kaligpt for more info.\e[0m"
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
      git -C /opt/KaliGPT describe --tags
    ;;

	--setup-keys|*)
		python3 main.py "$@"
		;;

esac
deactivate
EOF

# Make launcher executable
sudo chmod +x "$LAUNCHER_BIN_PATH"
stop_spinner "KaliGPT launcher creation"


# Final Message
echo -e "\e[1;32mKaliGPT v1.3 (HackerX) installed Successfully!\e[0m"
echo -e "\e[1;33mYou can run KaliGPT using the command: \e[0m\e[1;32mkaligpt\e[0m"

# test run with help flag
kaligpt --help