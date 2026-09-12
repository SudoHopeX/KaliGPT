#!/bin/bash
trap '[ -n "$SPIN_PID" ] && kill "$SPIN_PID" 2>/dev/null' EXIT
USER_NAME=$(logname 2>/dev/null)

# KaliGPT v1.3 Setup — Arch/Garuda adaptation
# Adapted from installer.deb.sh by SudoHopeX
# Arch adapter by: mrblack36

# Ensure script runs as root
if [ "$EUID" -ne 0 ]; then
  echo ""
  echo -e "\e[1;31mError: This script requires root privileges.\e[0m" >&2
  echo -e "\e[1;33mRequesting sudo privileges...\e[0m"
  exec sudo bash "$0" "$@"
fi

# Spinner
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
start_spinner() { spin "$1" & SPIN_PID=$!; }
stop_spinner()  {
  kill $SPIN_PID 2>/dev/null
  wait $SPIN_PID 2>/dev/null
  echo -e "\r\e[1;32m[✓] $1 complete! \e[0m"
}

# Install if missing — uses pacman, maps deb pkg names to Arch equivalents
install_if_missing() {
  declare -A pkg_map=(
    [python3]="python"
    [python3-pip]="python-pip"
    [python3-venv]=""          # built into python on Arch, skip
    [chromium]="chromium"
    [xvfb]="xorg-server-xvfb"
  )

  for pkg in "$@"; do
    arch_pkg="${pkg_map[$pkg]:-$pkg}"   # fall back to same name if not in map
    [[ -z "$arch_pkg" ]] && { echo -e "\r\e[1;32m[✓] $pkg — built-in on Arch, skipping.\e[0m"; continue; }

    if pacman -Qi "$arch_pkg" >/dev/null 2>&1; then
      echo -e "\r\e[1;32m[✓] $arch_pkg is already installed.\e[0m"
    else
      start_spinner "$arch_pkg Installing"
      pacman -S --noconfirm "$arch_pkg" > /dev/null 2>&1
      stop_spinner "$arch_pkg Installation"
    fi
  done
}

# ---- System update ----
echo ""
start_spinner "System Updating"
pacman -Sy > /dev/null 2>&1
stop_spinner "System Update"

# ---- Dependencies ----
echo ""
install_if_missing python3 python3-pip python3-venv chromium xvfb

# ---- Also make sure git is present ----
if ! pacman -Qi git >/dev/null 2>&1; then
  start_spinner "git Installing"
  pacman -S --noconfirm git > /dev/null 2>&1
  stop_spinner "git Installation"
fi

# ---- Clone KaliGPT ----
mkdir -p /opt/KaliGPT/
echo ""
start_spinner "Cloning KaliGPT repository"
git clone https://github.com/SudoHopeX/KaliGPT.git /opt/KaliGPT/ > /dev/null 2>&1
stop_spinner "KaliGPT Repository Clone"

# ---- Clone OpenSearchAPI ----
mkdir -p /opt/KaliGPT/OpenSearchAPI/
start_spinner "Cloning OpenSearchAPI repository"
git clone https://github.com/SudoHopeX/OpenSearchAPI.git /opt/KaliGPT/OpenSearchAPI/ > /dev/null 2>&1
stop_spinner "OpenSearchAPI repository clone"

# ---- Ollama (optional) ----
echo ""
read -p "Wanna install Ollama (to use local AI models) ? (y/N): " install_ollama
if [[ "$install_ollama" =~ ^[Yy]$ ]]; then
  echo -e "\e[1;32mProceeding with Ollama installation...\e[0m"
  start_spinner "Installing Ollama"
  curl -fsSL https://ollama.com/install.sh | sh > /dev/null 2>&1
  stop_spinner "Ollama Installation"

  read -p "Enter Ollama model to install (default: qwen3:8b): " ollama_model
  ollama_model=${ollama_model:-qwen3:8b}
  echo -e "\e[1;32m[+] Pulling Ollama model: $ollama_model (this may take a while)...\e[0m"
  ollama pull "$ollama_model"
  echo -e "\e[1;32m[✓] Ollama model $ollama_model pull complete!\e[0m"
else
  echo -e "\e[33mOllama AI models installation skipped.\e[0m"
fi

# ---- Python venv + pip requirements ----
python3 -m venv /opt/KaliGPT/its_venv
source /opt/KaliGPT/its_venv/bin/activate
cd /opt/KaliGPT/

echo ""
start_spinner "pip requirements Installing"
pip3 install -r requirements/pip-requirements.txt > /dev/null 2>&1
stop_spinner "pip Requirements Installation"

# ---- API key setup ----
echo ""
read -p "Do you want to set up API keys now? (Y/n): " setup_api
setup_api=${setup_api:-Y}
if [[ "$setup_api" =~ ^[Nn]$ ]]; then
  echo -e "\e[33mAPI key setup skipped. Run \e[0m\e[1;32mkaligpt --setup-keys\e[0m\e[33m later.\e[0m"
else
  echo -e "\e[1;32mProceeding with API key setup...\e[0m"
  python3 -m agents --setup-keys
fi

deactivate

# ---- Launcher: kaligpt ----
LAUNCHER_BIN_PATH="/usr/local/bin/kaligpt"
echo ""
start_spinner "Creating KaliGPT launcher at $LAUNCHER_BIN_PATH"
tee "$LAUNCHER_BIN_PATH" > /dev/null <<'EOF'
#!/bin/bash
source /opt/KaliGPT/its_venv/bin/activate
cd /opt/KaliGPT
OpenSearchAPI_PID=""

st_opensearchapi() { OpenSearchAPI_PID=$(opensearchapi --bg); }

MODE="$1"; shift

case "$MODE" in
  -g|--gemini)     st_opensearchapi; python3 -m agents.gemini "$@" ;;
  -o|--ollama)     st_opensearchapi; python3 -m agents.ollama "$@" ;;
  -or|--openrouter) st_opensearchapi; python3 -m agents.openrouter "$@" ;;
  -rq|--requesty)  st_opensearchapi; python3 -m agents.requesty "$@" ;;
  -c|--chatgpt)    st_opensearchapi; python3 -m agents.chatgpt "$@" ;;
  --web)           python3 -m agents.web_launcher "$@" ;;
  --setup-keys)    python3 -m agents "$MODE" ;;
  -u|--update)
    echo -e "\e[1;33mChecking for updates...\e[0m"
    git fetch origin hackerx
    LOCAL=$(git rev-parse HEAD); REMOTE=$(git rev-parse origin/hackerx)
    if [ "$LOCAL" != "$REMOTE" ]; then
      echo -e "\e[1;32mUpdating KaliGPT...\e[0m"
      git pull origin hackerx > /dev/null 2>&1 && bash /opt/KaliGPT/installers/installer.arch.sh
    else
      echo -e "\e[1;32mAlready up-to-date.\e[0m"
    fi ;;
  -v|--version) git describe --tags ;;
  -lr|--list-providers)
    echo -e "\e[1;33mKaliGPT Provides:\e[0m
1) Google Gemini Models   (Free/Paid, Online)  [ Requires API Key ]
2) OpenRouter Models      (Free/Paid, Online)  [ Requires API Key ]
3) Requesty Models        (Paid, Online)       [ Requires API Key ]
4) Ollama                 (Free, Offline)      [ Local AI Models  ]
5) OpenAI ChatGPT         (Paid, Online)       [ Requires API Key ]" ;;
  -h|--help)
    echo -e "\e[1;32mKaliGPT v1.3 — by SudoHopeX\e[0m"
    echo -e "Usage: kaligpt [MODE] [Prompt]"
    echo -e "  -g  --gemini        Gemini models"
    echo -e "  -o  --ollama        Ollama (offline)"
    echo -e "  -or --openrouter    OpenRouter models"
    echo -e "  -rq --requesty      Requesty models"
    echo -e "  -c  --chatgpt       OpenAI models"
    echo -e "  --web               Open AI web chat"
    echo -e "  --setup-keys        Configure API keys"
    echo -e "  -u  --update        Update KaliGPT"
    echo -e "  -v  --version       Show version"
    echo -e "  -lr --list-providers List providers" ;;
  *) st_opensearchapi; python3 -m agents "$MODE" "$@" ;;
esac

[ -n "$OpenSearchAPI_PID" ] && kill "$OpenSearchAPI_PID" > /dev/null 2>&1
deactivate
EOF
chmod +x "$LAUNCHER_BIN_PATH"
stop_spinner "KaliGPT launcher creation"

# ---- Launcher: opensearchapi ----
tee /usr/local/bin/opensearchapi > /dev/null <<'EOF'
#!/usr/bin/env bash
source /opt/KaliGPT/its_venv/bin/activate
if [ "$1" == "--bg" ]; then
  python /opt/KaliGPT/OpenSearchAPI/app.py > /dev/null 2>&1 &
  echo "$!"
else
  python /opt/KaliGPT/OpenSearchAPI/app.py
fi
deactivate
EOF
chmod +x /usr/local/bin/opensearchapi

# ---- Fix ownership ----
chown -R "$USER_NAME":"$USER_NAME" /opt/KaliGPT/
chmod 666 /opt/KaliGPT/agents/utils/api.config.json

# ---- Done ----
echo -e "\e[1;32mKaliGPT v1.3 (HackerX) installed successfully on Arch/Garuda!\e[0m"
echo -e "\e[1;33mRun it with: \e[0m\e[1;32mkaligpt\e[0m"
echo ""
kaligpt --help
