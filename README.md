# KaliGPT v1.1
> [!NOTE]
> New Features coming soon:) Tool Call, Online Search, Pretty print, better management
> Which can be found soon at [HackerX (KaliGPT v1.3)](https://github.com/SudoHopeX/KaliGPT/tree/hackerx)


![KaliGPT Logo](https://sudohopex.github.io/pages/project-docs/asset/KaliGPT-logo-transparent.png)

**KaliGPT** : An AI Agent assistance in Linux CLI for Ethical Hacking & Cybersecurity to use AI with ease to learn and master CyberSecurity

[![Release](https://img.shields.io/github/v/tag/SudoHopeX/KaliGPT?label=Release&color=informational&logo=github)](https://github.com/SudoHopeX/KaliGPT/tags)
[![GitHub Stars](https://img.shields.io/github/stars/SudoHopeX/KaliGPT?style=social)](https://github.com/SudoHopeX/KaliGPT/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/SudoHopeX/KaliGPT?style=social)](https://github.com/SudoHopeX/KaliGPT/network/members)
[![Last 14 Days Clones](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/SudoHopeX/KaliGPT/main/clones_count.json&label=Last%2014%20Days%20Clones&color=2ea44f&logo=git&style=flat)](https://github.com/SudoHopeX/KaliGPT/pulse)
[![Contributions Welcomed](https://img.shields.io/badge/Contributions-Welcomed-violet.svg)](https://github.com/SudoHopeX/KaliGPT/CONTRIBUTING.md)

⭐ Star this repo if you found it helpful!

## Models

- ChatGPT 4.0
- Gemini 2.5 Flash
- Mistral / Llama 3
- OpenAI GPT's - browser-based if API access is unavailable

This tool ensures flexibility whether you have paid API access, want to run models locally, or prefer using the web interface via your browser.

## Features

- **Automated installation** 
- **Flexible AI backend selection**
- **Command-line and graphical interfaces**
- **Web automation**: If no API is available, script can launch Chromium (browser configurable) for web-based chat with arg `-cw`.
- **Open source & MIT Licensed**

## Base Requirements

- Linux OS ( to be tested on Kali, Debian, etc. ) with Bash Shell
- Python 3.x 
- Chromium or other supported browsers ( for web use )

## Installation

- Clone the repository and run the installer:
  ```
  git clone https://github.com/SudoHopeX/KaliGPT.git
  ```

- Move to KaliGPT
  ```
  cd KaliGPT
  ```

- Install a KaliGPT Model
  ```
  sudo bash kaligpt_unified.sh --model <model-number>
  ```
see kaligpt installer usages for more

## KaliGPT Installer Usages
execute ` bash kaligpt_unified.sh --help ` to see this (below given) usages

```
KaliGPT Installer ~ SudoHopeX | Krishna Dwivedi

KaliGPT Installer Available commands:
   --model <model-num>         -  install a specific model
   --listmodels                -  list available models
   --uninstall-m <model-num>   -  uninstall a specific model
   --uninstall                 -  uninstall KaliGPT (everything)
   --help                      -  print this usage info

KaliGPT Available MODELs:
   1) OpenAI ChatGPT ( OpenAI, Free, Online ) [ Requires API KEY ]
   2) Mistral    ( Free, Offline - Min 6GB Data Required)
   3) Llama      ( Free, Offline )
   4) KaliGPT -web based ( OpenAI, Free, Online )
   5) Google Gemini 2.5 Flash (Google, Free, Online) Required API Key ]
      [Note: opttion 4 required 1 time logging & keep logged in config in chromium if not]

Usages Examples:
   sudo bash kaligpt_unified.sh --model 1       # install OpenAI ChatGPT4.0 with API access
   sudo bash kaligpt_unified.sh --model 2       # install KaliGPT (Mistral AI locally)
   bash kaligpt_unified.sh --help               # print script usages
   sudo bash kaligpt_unified.sh --uninstall-m 1 # uninstall OpenAI installed files
   sudo bash kaligpt_unified.sh --uninstall     # uninstall KaliGPT (everything)

```

## KaliGPT Usages
use command `kaligpt-h` to see below usages after installation

```
KaliGPT - Use AI in Linux via CLI easily
        - by SudoHopeX | Krishna Dwivedi

Usages:
        kaligpt [MODE] [FLAG(Optional)] [Prompt (Optional)]

MODES: (Must Included)

    -c  [--chatgpt]           =  use ChatGPT-4o (Online)
    -cw [--chatgpt-web]       =  use KaliGPT in Web Browser (Online)
                    ( requires 1 time login & keep logged in configs on web )
    -g  [--gemini]            =  use Gemini 2.5 Flash (Online)
    -m  [--mistral]           =  use Mistral via Ollama (Offline)
    -l  [--llama]             =  use LlaMa via Ollama (Offline)
    -i  [--install]           = install a model bu using --model <model-num>
    -lm [--list-models]       = list KaliGPT available models
    -u  [--uninstall]         = uninstall a model or KaliGPT (everything)
    -h  [--help]              =  show this help message and exit

FLAGS:
    --model <model-num>        = specify a model to install (with --install)
    --uninstall-m <model-num>  =  uninstall a specific model (with --uninstall)
    --uninstall-k              =  uninstall KaliGPT (everything) (with --uninstall)


Examples:
     kaligpt -g "How to Scan a website for subdomains using tools"
     kaligpt -l "Help me find XXS on a target.com"
     kaligpt --install --model 5
     kaligpt -u --uninstall-m 1
     kaligpt -cw

 NOTE: do not pass prompt with -cw
       Must include a MODE & use flags only with specified mode
       Read README.md or Documentation at sudohopex.github.io for more info. 
```

## Switching AI Backends
- You can choose between:
  - **ChatGPT 4.0** (API key required, paid)
  - **Gemini 2.5 Flash** (API Key required, Free)
  - **Mistral or Llama 3** (local, free, via Ollama, resource intensive) [ Development going for low end systems ]
  - **Web interface** (no key required, but automates browser only for KaliGPT via OpenAI)

## Changing Default Browser for KaliGPT web:
To switch from Chromium to another browser:
1. Open `/usr/local/bin/kaligpt` in a text editor with sudo priviledge.
2. Find the section referencing `chromium` and comment it
3. Uncomment or add your preferred browser's binary (e.g., `firefox`, `brave-browser`, etc.). 
4. Save the script.

## License

Read Licence for details [License](LICENSE).

## Contributing
Contributions are welcome! Please open an issue to discuss your ideas or report bugs.


## Disclaimer
- This script is in testing phase now...
- This script is provided with no warranty. Use at your own risk, especially when modifying system binaries or running third-party models.


##   
![Made with L0V3 by SudoHopeX](https://sudohopex.github.io/img/made-with-love-by-sudohopex.png)
