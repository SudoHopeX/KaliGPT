[//]: #  ( SudoHopeX - KaliGPT )
[//]: #  ( Updated: 30 Jan 2026 )

# HackerX ( KaliGPT v1.3 )

<!-- ![KaliGPT Logo](https://sudohopex.github.io/pages/project-docs/asset/KaliGPT-logo-transparent.png) -->

**KaliGPT** : An AI Agent assistance in Linux CLI for Ethical Hacking & Cybersecurity to use AI with ease to learn and master CyberSecurity

**⭐ Star this repo if you found it helpful!**


## Badges
<div align="center">
 
<!-- Repository Statistics -->
[![Release](https://img.shields.io/github/v/tag/SudoHopeX/KaliGPT?label=Release&color=0078D4&style=for-the-badge&logo=github)](https://github.com/SudoHopeX/KaliGPT/tags)
[![Stars](https://img.shields.io/github/stars/SudoHopeX/KaliGPT?label=Stars&color=FFD700&style=for-the-badge&logo=reverbnation&logoColor=black)](https://github.com/SudoHopeX/KaliGPT/stargazers)
[![Forks](https://img.shields.io/github/forks/SudoHopeX/KaliGPT?label=Forks&color=28a745&style=for-the-badge&logo=github)](https://github.com/SudoHopeX/KaliGPT/network/members)
 
<!-- Traffic & Clones (Dynamic JSON) -->
![Clones](https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/SudoHopeX/KaliGPT/hackerx/clones_lifetime.json&query=$.message&label=Clones&color=A52A2A&style=for-the-badge&logo=git&logoColor=white)
![Views](https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/SudoHopeX/KaliGPT/hackerx/views_lifetime.json&query=$.message&label=Views&color=800080&style=for-the-badge&logo=github&logoColor=white)


<!-- Project & Community Badges -->
[![License](https://img.shields.io/badge/License-Open_Source-green?style=for-the-badge&logo=opensourceinitiative&logoColor=white)](LICENSE)
[![Contributions Welcomed](https://img.shields.io/badge/Contributions-Welcomed-violet?style=for-the-badge&logo=githubsponsors&logoColor=white)](https://github.com/SudoHopeX/KaliGPT/issues/new)
</div>

------
<!-- Feature & Support Badges -->
<div align="center">
 
![Automated Installation](https://img.shields.io/badge/Automated_Installation-0078D4?style=for-the-badge&logo=powershell&logoColor=white)
![Flexible AI](https://img.shields.io/badge/Flexible_AI_Backend-FF6F00?style=for-the-badge&logo=deepmind&logoColor=white)
![CLI](https://img.shields.io/badge/CLI_Interface-4EAA25?style=for-the-badge&logo=gnumetadataterminal&logoColor=white)
![Tool Call](https://img.shields.io/badge/Tool_Calling-61DAFB?style=for-the-badge&logo=react&logoColor=black)
![Online Search](https://img.shields.io/badge/Online_Search-4285F4?style=for-the-badge&logo=google&logoColor=white)
[![Termux Support](https://img.shields.io/badge/Termux_Supported-EF3939?style=for-the-badge&logo=termux&logoColor=white)](https://github.com/SudoHopeX/KaliGPT/tree/hackerx)
</div>

------
<!-- Available Backends-->
<div align="center">

![Gemini](https://img.shields.io/badge/Gemini-8E75FF?style=for-the-badge&logo=googlegemini&logoColor=white)
![Ollama](https://img.shields.io/badge/Ollama-000000?style=for-the-badge&logo=ollama&logoColor=white)
![OpenRouter](https://img.shields.io/badge/OpenRouter-6566f1?style=for-the-badge&logo=openrouter&logoColor=white)
![ChatGPT](https://img.shields.io/badge/ChatGPT-74aa9c?style=for-the-badge&logo=openai&logoColor=white)
<!-- ![Claude](https://img.shields.io/badge/Claude-D97757?style=for-the-badge&logo=anthropic&logoColor=white) -->
</div>

## Installation

### Automated Installation (Recommended) - detects env & installs KaliGPT
1. switch to superuser (root) -  [ skip this step in Termux]
    ```commandline
    sudo su
    ```
    Enter the password &
2. Use curl to install kaligpt
    ```
    bash <(curl -sL https://raw.githubusercontent.com/SudoHopeX/KaliGPT/refs/heads/hackerx/install.sh)
    ```

### Manual Installation (Required twice cloning of repo)
#### Debian (e.g. Kali, Ubuntu etc.)
- Clone the GitHub repository's `hackerx` branch :
  ```
  git clone https://github.com/SudoHopeX/KaliGPT.git && cd KaliGPT
  ```

- install KaliGPT for debian
  ```commandline
  sudo bash install.sh -m
  ```

#### Termux
- Install `git` and `bash` ( if not installed ):
   ```commandline
   pkg install git bash
   ```

- Clone the GitHub repository's `hackerx` branch & install KaliGPT:
  ```
  git clone https://github.com/SudoHopeX/KaliGPT.git && cd KaliGPT
  ```
- install KaliGPT for Termux
  ```commandline
  bash install.sh -m
  ```

## KaliGPT Usages
use command `kaligpt -h` to see below usages after installation

```help
  HackerX (KaliGPT v1.3) - Use AI in Linux via CLI easily
                         - by SudoHopeX | Krishna Dwivedi

Usages:
        kaligpt [MODE(Optional)] [Prompt(Optional)]

MODES:
    -g  [--gemini]            =  use Gemini models (Online, tool call)
    -o  [--ollama]            =  use local models via Ollama (Offline)
    -or [--openrouter]        =  use OpenRouter models (Online, tool call)
    -c  [--chatgpt]           =  use OpenAI models (Online, tool call)
    --web                     =  AIs official Web-Chat Opener (Online)
    --setup-keys              =  setup API keys for online models
    -u [--update]             =  update KaliGPT to latest version
    -v [--version]            =  show KaliGPT version and exit
    -lr [--list-providers]    =  list KaliGPT available providers (vendors)
    -h  [--help]              =  show this help message and exit
    

Examples:
     kaligpt  ( uses default model and will ask for prompt )
     kaligpt "Help me find XSS on target.com"
     kaligpt -g "How to Scan a website for subdomains using tools"
     kaligpt -or "Help me find XXS on a target.com"
     kaligpt --web   (launches default AI model web Chat

```
<!-- Read README.md or Documentation at https://hope.is-a.dev/?path=kaligpt for more info.  -->

## Requirements
Read all Requirements on [Requirements](/requirements/globals.md)

## Disclaimer
- This script is provided with no warranty. Use at your own risk, especially when modifying system binaries or running third-party models.

##   
<div align="center">
  <a href="https://hope.is-a.dev">
    <img src="https://hope.is-a.dev/img/made-with-love-by-sudohopex.png" style="width:300px;height:auto;" alt="Made with L0V3 by SudoHopeX">
  </a>
</div>   
