[//]: #  ( SudoHopeX - KaliGPT )
[//]: #  ( Updated: 14 feb 2026 )


<div align="center">
  <a href="https://github.com/SudoHopeX/KaliGPT">
    <img src="https://hope.is-a.dev/pages/project-docs/asset/hackerx-green-white-transparent.png" style="width:600px;height:auto;" alt="HackerX KaliGPT v1.3 - Made with L0V3 by SudoHopeX">
  </a>
</div>

# HackerX ( KaliGPT v1.3 )
**KaliGPT** : An Agentic assistance in Linux CLI for Ethical Hacking & Cybersecurity to use AI with ease to learn and master CyberSecurity

### **⭐ Star this repo if you found it helpful!**


## Badges
<div align="center">

<!-- GitHub Trending -->
<a href="https://trendshift.io/repositories/36967?utm_source=repository-badge&amp;utm_medium=badge&amp;utm_campaign=badge-repository-36967" target="_blank" rel="noopener noreferrer"><img src="https://trendshift.io/api/badge/repositories/36967" alt="SudoHopeX%2FKaliGPT | Trendshift" width="250" height="55"/></a>
<!-- SudoHopeX/KaliGPT has been featured on GitHub Trending, first reaching #10 on Jun 7, 2026 -->
---
 
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
[![OpenSearchAPI](https://img.shields.io/badge/OpenSearchAPI-4285F4?style=for-the-badge&logo=globe&logoColor=black)](https://github.com/SudoHopeX/OpenSearchAPI)
[![Termux Support](https://img.shields.io/badge/Termux_Supported-EF3939?style=for-the-badge&logo=termux&logoColor=white)](https://github.com/SudoHopeX/KaliGPT/tree/hackerx)
</div>

------
<!-- Available Backends-->
<div align="center">

![Gemini](https://img.shields.io/badge/Gemini-8E75FF?style=for-the-badge&logo=googlegemini&logoColor=white)
![Ollama](https://img.shields.io/badge/Ollama-000000?style=for-the-badge&logo=ollama&logoColor=white)
![OpenRouter](https://img.shields.io/badge/OpenRouter-6566f1?style=for-the-badge&logo=openrouter&logoColor=white)
![ChatGPT](https://img.shields.io/badge/ChatGPT-74aa9c?style=for-the-badge&logo=openai&logoColor=white)
![LiteLLM](https://img.shields.io/badge/🚅_LiteLLM-7C3AED?style=for-the-badge&logoColor=white)
<!-- ![Claude](https://img.shields.io/badge/Claude-D97757?style=for-the-badge&logo=anthropic&logoColor=white) -->
</div>

## Installation

1. Download KaliGPT Installer
    ```
    curl -sL https://raw.githubusercontent.com/SudoHopeX/KaliGPT/refs/heads/hackerx/install.sh | bash
    ```
    > Note: Use within permitted directory without root user
2. Install KaliGPT ( don't use sudo in Termux )
   ```
   sudo bash kaligptinstaller.sh
   ```

## KaliGPT Usages
use command `kaligpt -h` to see below usages after installation

```help
  HackerX (KaliGPT v1.3) - Use AI in Linux via CLI easily
                         - by SudoHopeX | Krishna Dwivedi

Usages:
        kaligpt [MODE(Optional)] [Prompt(Optional)]

MODES:
    -g  [--gemini]            =  use Gemini models (Online)
    -o  [--ollama]            =  use local models via Ollama (Offline,cloud:online )
    -or [--openrouter]        =  use OpenRouter models (Online)
    -c  [--chatgpt]           =  use OpenAI models (Online)
    -ll [--litellm]           =  use 100+ providers via LiteLLM (Online)
    --web                     =  AIs official Web-Chat Opener (Online)
    --setup-keys              =  setup API keys for online models
    -u [--update]             =  update KaliGPT to latest version
    -v [--version]            =  show KaliGPT version and exit
    -lr [--list-providers]    =  list KaliGPT available providers (vendors)
    -h  [--help]              =  show this help message and exit

Model Management:
    /change-model             = change to a different AI model
    /reset-to-default-model   = reset to KaliGPT default AI model (Gemini)
    /list-tools               = list available tools for AI Agent

Examples:
     kaligpt  ( uses default model and will ask for prompt )
     kaligpt "Help me find XSS on target.com"
     kaligpt -g "How to Scan a website for subdomains using tools"
     kaligpt -or "Help me find XXS on a target.com"
     kaligpt --web   (launches default AI model web Chat

```
<!-- Read README.md or Documentation at https://hope.is-a.dev/?path=kaligpt for more info.  -->

## Requirements
Read all Requirements [here](/requirements/globals.md)

## Disclaimer
> [!WARNING]
> :warning: HackerX (KaliGPT v1.3) is in active development, so don't expect it to work flawlessly. Instead, contribute by raising an issue or [sending a PR](https://github.com/SudoHopeX/KaliGPT/pulls).
>
> Access to this library and the use of information, materials (or portions thereof), is **<u>not intended</u>, and is <u>prohibited</u>, where such access or use violates applicable laws or regulations**. By no means the authors encourage or promote the unauthorized tampering with running systems. This can cause serious human harm and material damages.
>
> *By no means the authors of HackerX (KaliGPT v1.3) encourage or promote the unauthorized tampering with compute systems. Please don't use the source code in here for cybercrime. <u>Pentest for good instead</u>*. By downloading, using, or modifying this source code, you agree to the terms of the [`LICENSE`](LICENSE) and the limitations outlined in the [`DISCLAIMER`](DISCLAIMER) file.


##   
<div align="center">
  <a href="https://hope.is-a.dev">
    <img src="https://hope.is-a.dev/img/made-with-love-by-sudohopex.png" style="width:300px;height:auto;" alt="Made with L0V3 by SudoHopeX">
  </a>
</div>   
