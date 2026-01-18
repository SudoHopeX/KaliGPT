# HackerX ( KaliGPT v1.3 ) @ Under Development

<!-- ![KaliGPT Logo](https://sudohopex.github.io/pages/project-docs/asset/KaliGPT-logo-transparent.png) -->

**KaliGPT** : An AI Agent assistance in Linux CLI for Ethical Hacking & Cybersecurity to use AI with ease to learn and master CyberSecurity

<!--
[![Release](https://img.shields.io/github/v/tag/SudoHopeX/KaliGPT?label=Release&color=informational&logo=github)](https://github.com/SudoHopeX/KaliGPT/tags)
[![GitHub Stars](https://img.shields.io/github/stars/SudoHopeX/KaliGPT?style=social)](https://github.com/SudoHopeX/KaliGPT/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/SudoHopeX/KaliGPT?style=social)](https://github.com/SudoHopeX/KaliGPT/network/members)
 [![Last 14 Days Clones](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/SudoHopeX/KaliGPT/main/clones_count.json&label=Last%2014%20Days%20Clones&color=2ea44f&logo=git&style=flat)](https://github.com/SudoHopeX/KaliGPT/pulse) 
 -->

**⭐ Star this repo if you found it helpful!**


## Features
![Release v1.3 beta](https://img.shields.io/badge/Release-v1.3_beta-voilet?style=flat-square&color=blue&label=)
![Automated Installation](https://img.shields.io/badge/-Automated_Installation-brightgreen?style=flat-square&color=blue&label=)
![Flexible AI Backend Selection](https://img.shields.io/badge/-Flexible_AI_backend_selection-brightblue?style=flat-square&color=pink&label=)
![CLI](https://img.shields.io/badge/-Command_Line_Interface-brightpink?style=flat-square&color=brightgreen&label=)
![Tool Call](https://img.shields.io/badge/-Tool_Call-brightgreen?style=flat-square&color=blue&label=)
![Online Search](https://img.shields.io/badge/-Online_Search-brightblue?style=flat-square&color=pink&label=)
[![License](https://img.shields.io/badge/License-Open_Source-brightgreen.svg)](LICENSE)
[![Contributions Welcomed (Open a issue to discuss ideas & bugs)](https://img.shields.io/badge/Contributions-Welcomed_%28Open_a_issue%29-violet.svg)](https://github.com/SudoHopeX/KaliGPT/issues/new)
[![Termux Support](https://img.shields.io/badge/Termux_Supported-violet.svg)](https://github.com/SudoHopeX/KaliGPT)

## Installation

- Use curl to install kaligpt ( Recommended )
  ```
  curl -sL https://hope.is-a.dev/kaligpt/install.sh | bash
  ```
  
- Clone the GitHub repository's `hackerx` branch & install KaliGPT for debian:
  ```
  git clone --branch hackerx --single-branch https://github.com/SudoHopeX/KaliGPT.git && sudo bash KaliGPT/install.sh
  ```
> [!NOTE]
> Do not use sudo while installing in Termux   

## KaliGPT Usages
use command `kaligpt -h` to see below usages after installation

```
  HackerX (KaliGPT v1.3) - Use AI in Linux via CLI easily
                         - by SudoHopeX | Krishna Dwivedi

Usages:
        kaligpt [MODE(Optional)] [Prompt(Optional)]

MODES:
    -g  [--gemini]            =  use Gemini models (Online, tool call)
    -o  [--ollama]            =  use local models via Ollama (Offline)
    -or [--openrouter]        =  use OpenRouter models (Online, tool call)
    -lr [--list-vendors]      =  list KaliGPT available vendor model's
    -h  [--help]              =  show this help message and exit
    --update                  = check & install updates if any

Examples:
     kaligpt  ( uses default model and will ask for prompt )
     kaligpt "Help me find XSS on target.com"
     kaligpt -g "How to Scan a website for subdomains using tools"
     kaligpt -or "Help me find XXS on a target.com"

Read README.md or Documentation at https://hope.is-a.dev/?path=kaligpt for more info. 
```

## Available AI Backends Vendors
![Gemini](https://img.shields.io/badge/-Gemini-brightgreen?style=flat-square&color=blue&label=)
![Ollama](https://img.shields.io/badge/-Ollama-brightgreen?style=flat-square&color=blue&label=)
![OpenRouter](https://img.shields.io/badge/-OpenRouter-brightgreen?style=flat-square&color=blue&label=)
<!-- ![ChatGPT](https://img.shields.io/badge/-ChatGPT-brightgreen?style=flat-square&color=blue&label=) -->
<!-- ![Claude](https://img.shields.io/badge/-Claude-brightgreen?style=flat-square&color=blue&label=) -->


## Disclaimer
- This script is provided with no warranty. Use at your own risk, especially when modifying system binaries or running third-party models.

##   
<div align="center">
  <a href="https://hope.is-a.dev">
    <img src="https://sudohopex.github.io/img/made-with-love-by-sudohopex.png" style="width:300px;height:auto;" alt="Made with L0V3 by SudoHopeX">
  </a>
</div>   
