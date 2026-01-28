# HackerX ( KaliGPT v1.3 ) @ Under Development

<!-- ![KaliGPT Logo](https://sudohopex.github.io/pages/project-docs/asset/KaliGPT-logo-transparent.png) -->

**KaliGPT** : An AI Agent assistance in Linux CLI for Ethical Hacking & Cybersecurity to use AI with ease to learn and master CyberSecurity


<!--
[![GitHub Stars](https://img.shields.io/github/stars/SudoHopeX/KaliGPT?style=social)](https://github.com/SudoHopeX/KaliGPT/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/SudoHopeX/KaliGPT?style=social)](https://github.com/SudoHopeX/KaliGPT/network/members)
 [![Last 14 Days Clones](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/SudoHopeX/KaliGPT/main/clones_count.json&label=Last%2014%20Days%20Clones&color=2ea44f&logo=git&style=flat)](https://github.com/SudoHopeX/KaliGPT/pulse) 
 -->

**⭐ Star this repo if you found it helpful!**


## Features
[![Release](https://img.shields.io/github/v/tag/SudoHopeX/KaliGPT?label=Release&color=informational&logo=github)](https://github.com/SudoHopeX/KaliGPT/tags)
<!--[![Release - v1.3 beta](https://img.shields.io/badge/Release-v1.3_beta-brightgreen.svg)](https://github.com/SudoHopeX/KaliGPT/tree/hackerx)-->
![Automated Installation](https://img.shields.io/badge/-Automated_Installation-brightgreen?style=flat-square&color=blue&label=)
![Flexible AI Backend Selection](https://img.shields.io/badge/-Flexible_AI_backend_selection-brightblue?style=flat-square&color=pink&label=)
![CLI](https://img.shields.io/badge/-Command_Line_Interface-brightpink?style=flat-square&color=brightgreen&label=)
![Tool Call](https://img.shields.io/badge/-Tool_Call-brightgreen?style=flat-square&color=blue&label=)
![Online Search](https://img.shields.io/badge/-Online_Search-brightblue?style=flat-square&color=pink&label=)
[![License](https://img.shields.io/badge/License-Open_Source-brightgreen.svg)](LICENSE)
[![Contributions Welcomed (Open a issue to discuss ideas & bugs)](https://img.shields.io/badge/Contributions-Welcomed_%28Open_a_issue%29-violet.svg)](https://github.com/SudoHopeX/KaliGPT/issues/new)
[![Termux Support](https://img.shields.io/badge/-Termux_Supported-brightblue?style=flat-square&color=pink&label=)](https://github.com/SudoHopeX/KaliGPT/tree/hackerx)


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
  git clone --branch hackerx --single-branch https://github.com/SudoHopeX/KaliGPT.git && cd KaliGPT
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
  git clone --branch hackerx --single-branch https://github.com/SudoHopeX/KaliGPT.git && cd KaliGPT
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

Read README.md or Documentation at https://hope.is-a.dev/?path=kaligpt for more info. 
```

## Available AI Backends Vendors
![Gemini](https://img.shields.io/badge/-Gemini-brightgreen?style=flat-square&color=blue&label=)
![Ollama](https://img.shields.io/badge/-Ollama-brightgreen?style=flat-square&color=blue&label=)
![OpenRouter](https://img.shields.io/badge/-OpenRouter-brightgreen?style=flat-square&color=blue&label=)
![ChatGPT](https://img.shields.io/badge/-ChatGPT-brightgreen?style=flat-square&color=blue&label=)
<!-- ![Claude](https://img.shields.io/badge/-Claude-brightgreen?style=flat-square&color=blue&label=) -->

## Requirements
All Requirements can be found at [Requirements](/requirements/globals.md)

## Disclaimer
- This script is provided with no warranty. Use at your own risk, especially when modifying system binaries or running third-party models.

##   
<div align="center">
  <a href="https://hope.is-a.dev">
    <img src="https://hope.is-a.dev/img/made-with-love-by-sudohopex.png" style="width:300px;height:auto;" alt="Made with L0V3 by SudoHopeX">
  </a>
</div>   
