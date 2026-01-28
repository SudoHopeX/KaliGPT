# !/bin/bash
trap "kill $SPIN_PID 2>/dev/null" EXIT


# KaliGPT v1.3 Setup (check & install dependencies, create launcher) Script for Termux
# by SudoHopeX ( SudoHopeX )
# Last Modified: 28 Jan 2026


# Global variables
BIN_PATH="/data/data/com.termux/files/usr/bin/kaligpt"
INSTALL_DIR="/data/data/com.termux/files/usr/share/KaliGPT"


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

install_if_missing() {
    for pkg in "$@"; do
      if ! pkg list-installed "$pkg" >/dev/null 2>&1; then
          start_spinner "$pkg Installing..."
          pkg install "$pkg" -y > /dev/null 2>&1
          stop_spinner "$pkg Installation"
      else
          echo -e "\r\e[1;32m[✓] $pkg is already installed.\e[0m"
      fi
    done
}

# ---- Performing system update & upgrade ----
echo ""
start_spinner "System Updating"
pkg update && pkg upgrade -y > /dev/null 2>&1
stop_spinner "System Update"

# ---- checking and installing missing pkgs ----
echo ""
install_if_missing python python-pip golang-go git lixxml2 libxslt libjpeg-turbo libpng freetype littlecms openjpeg libtiff clang make pkg-config rust

# ---- creating KaliGPT installation directory ----
mkdir -p "$INSTALL_DIR"

# ----- KaliGPT v1.3 (HackerX) Source Cloning -----
echo ""
start_spinner "Cloning KaliGPT repository"
git clone --branch hackerx --single-branch https://github.com/SudoHopeX/KaliGPT.git "$INSTALL_DIR/" > /dev/null 2>&1
stop_spinner "KaliGPT repository clone"


# ----- Cloning and setting up OpenSerp -----
echo ""
start_spinner "Cloning OpenSerp repository"
git clone https://github.com/karust/openserp.git "$INSTALL_DIR/openserp/" > /dev/null 2>&1
stop_spinner "OpenSerp repository clone"

start_spinner "Building OpenSerp binary"
cd "$INSTALL_DIR/openserp/" && go build -o openserp . > /dev/null 2>&1
cd ..
stop_spinner "OpenSerp binary build"


# ----- Installing pip requirements -----
echo ""
start_spinner "pip requirements Installing"
pip3 install openai google-genai rich requests newspaper3k lxml_html_clean  > /dev/null 2>&1
stop_spinner "pip Requirements Installation"

# ----- API KEY configuration setup -----  ( if N skip, else start setup )
echo ""
read -p "Do you want to set up API keys now? (Y/n): " setup_api
if [[ "$setup_api" =~ ^[Nn]$ ]]; then
    echo -e "\e[33mAPI key setup skipped by user. You can set up API keys later using \"kaligpt --setup-keys\".\e[0m"
else
    echo -e "\e[1;32mProceeding with API key setup...\e[0m"
    python3 -m agents --setup-keys
fi


# ----- Creating launcher -----
echo ""
start_spinner "Creating KaliGPT launcher at $BIN_PATH"
cat << EOF > "$BIN_PATH"
#!/bin/bash
export PYTHONPATH="\$PYTHONPATH:$INSTALL_DIR"
INSTALL_DIR="$INSTALL_DIR"
BIN_PATH="$BIN_PATH"

# KaliGPT v1.3 Launcher Script for Termux
# by SudoHopeX ( https://github.com/SudoHopeX )

MODE="\$1"
shift

cd "\$INSTALL_DIR/"

# start the openserp server in background
start_openserp() {
    cd "\$INSTALL_DIR/openserp"
    nohup ./openserp serve > /dev/null 2>&1 &
    cd "\$INSTALL_DIR/"
}

case "\$MODE" in

        -g|--gemini)
                start_openserp
                python3 -m agents.gemini "\$@"
                ;;

        # -o|--ollama)
                  # To use ollama on termux, user needs to provide ollama endpoint url but will be made available later
                  # start_openserp
                  # python3 -m agents.ollama "\$@"
                  # ;;

        -or|--openrouter)
                  start_openserp
                  python3 -m agents.openrouter "\$@"
                  ;;

        -c|--chatgpt)
                start_openserp
                python3 -m agents.chatgpt "$@"
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
            # Check for updates
            echo -e "\e[1;33mChecking for updates...\e[0m"
            git fetch origin hackerx
            LOCAL=\$(git rev-parse HEAD)
            REMOTE=\$(git rev-parse origin/hackerx)
            if [ \$LOCAL != \$REMOTE ]; then
                echo -e "\e[1;32mNew version found! Updating KaliGPT...\e[0m"
                git pull origin hackerx > /dev/null 2>&1
                bash installers/installer.termux.sh
                echo -e "\e[1;32mKaliGPT has been updated to the latest version!\e[0m"
            else
                echo -e "\e[1;32mKaliGPT is already up-to-date.\e[0m"
            fi
            ;;

      -v|--version)
            # printing version info from git tags
            # git describe --tags
            echo "HackerX (KaliGPT v1.3)"
            ;;

      --list-backends)
            echo -e "\e[1;33mKaliGPT Provides:\e[0m
            1) Google Gemini Models  ( Free/Paid, Online) [ Requires API Key ]
            2) OpenRouter Models (Various, Free/Paid, Online) [ Requires API Key ]
            "
            ;;

      --setup-keys)
            python3 -m agents --setup-keys
            ;;

      *)
            start_openserp
            python3 -m agents "\$MODE" "\$@"
            ;;
esac
EOF


chmod +x "$BIN_PATH"
stop_spinner "KaliGPT launcher created at $BIN_PATH"

echo -e "\e[1;32mKaliGPT v1.3 (HackerX) installation completed successfully!\e[0m"
echo -e "\e[1;32mYou can run KaliGPT using the command:\e[0m \e[1;34mkaligpt\e[0m"


# test command
kaligpt --help
