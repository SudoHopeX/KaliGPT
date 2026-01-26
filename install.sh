# !/bin/bash
trap "kill $SPIN_PID 2>/dev/null" EXIT


# /install.sh for selecting the distribution specific installer
# Detect the OS/env type (e.g. debian based system, termux etc.)
# by SudoHopeX ( https://github.com/SudoHopeX )
# Last Modified: 18 Jan 2026


# Function to detect if running in Termux  [ 0: True, 1: False ]
is_termux() {
    if [[ "$PREFIX" == */com.termux* ]]; then
        return 0
    elif [[ "$OSTYPE" == "linux-android"* ]]; then
        # "Termux (via OSTYPE)"
        return 0
    else
        return 1
    fi
}


# Detect the Linux distribution type (e.g., Debian-based, Arch, etc.) and returns the distro name
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID" | tr '[:upper:]' '[:lower:]'
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    elif [[ -f /etc/redhat-release ]]; then
        echo "rhel"
    elif [[ -f /etc/SuSE-release ]]; then
        echo "suse"
    else
        echo "unknown"
    fi
}


# Main logic
echo "🔍 Detecting environment..."
MODE="$1"


if is_termux; then
    echo "📱 Termux environment detected. Proceeding with Termux installer..."
    case "$MODE" in
      -m)
        bash installers/installer.termux.sh
        ;;
      *)
        bash <(curl -sL https://raw.githubusercontent.com/SudoHopeX/KaliGPT/refs/heads/hackerx/installers/install.termux.sh)
        ;;
    esac
    exit 0

else
    linux_distro=$(detect_distro)

    case "$linux_distro" in
        debian|kali|ubuntu|linuxmint)
            echo "🐧 Debian-based system detected ($linux_distro). Proceeding with Debian installer..."
            case "$MODE" in
              -m)
                sudo bash installers/installer.deb.sh
                ;;
              *)
                bash <(curl -sL https://raw.githubusercontent.com/SudoHopeX/KaliGPT/refs/heads/hackerx/installers/installer.deb.sh)
                ;;
            esac
            exit 0
            ;;
        arch|manjaro)
            echo "🐧 Arch-based system detected ($linux_distro). Arch installer not yet implemented."
            echo "Contact: [SudoHopeX](https://hope.is-a.dev/Link-tree)"
            exit 1
            ;;
        rhel|fedora|centos)
            echo "🐧 RHEL-based system detected ($linux_distro). RHEL installer not yet implemented."
            echo "Contact: [SudoHopeX](https://hope.is-a.dev/Link-tree)"
            exit 1
            ;;
        suse|opensuse)
            echo "🐧 SUSE-based system detected ($linux_distro). SUSE installer not yet implemented."
            echo "Contact: [SudoHopeX](https://hope.is-a.dev/Link-tree)"
            exit 1
            ;;
        *)
            echo -e "\e[1;31m❌ Unsupported or undetected Linux distribution: $linux_distro\e[0m"
            echo "Contact: [SudoHopeX](https://hope.is-a.dev/Link-tree)"
            exit 1
            ;;
    esac
fi
