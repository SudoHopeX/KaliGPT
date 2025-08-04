# KaliGPT Unified Installer v1.0 ~ SudoHopeX

## Overview

**KaliGPT Unified Installer** is a comprehensive bash script designed to automate the installation and usage of KaliGPT (ChatGPT/ChatGPT KaliGPT/Mistral/llama3) on Linux systems. It provides both CLI and GUI options for interacting with state-of-the-art AI models, including:

- ChatGPT 4.0 (via API using Python opanai latest module)
- Mistral and Llama 3 (via local installs using Ollama)
- KaliGPT (OpenAI GPT) - Web (browser-based) if API access is unavailable

This tool ensures flexibility whether you have paid API access, want to run models locally, or prefer using the web interface via your browser.

## Features

- **Automated installation** of all dependencies for KaliGPT, including Python requirements and Ollama setup.
- **Flexible AI backend selection**: Use ChatGPT 4.0 API, local Mistral/Llama 3 via Ollama, or web interface for OpenAI GPT.
- **Command-line and graphical interfaces**: Interact via terminal or GUI (if available).
- **Web automation**: If no API is available, script can launch Chromium (or other browsers, configurable via editing the binary) for web-based chat with arg `-cw`.
- **Open source & MIT Licensed**.

## Requirements

- Linux system ( to be tested on Kali, Debian, etc. )
- Bash shell
- Python 3.x (for API/CLI)
- openai python module ( library )
- requests python module ( library )
- Ollama ( for local models )
- Chromium or other supported browsers ( for web use )
- Internet connection ( for API / initial setup / OpenAI GPT's usages)

## Installation

- Clone the repository and run the installer:
  ```
  git clone https://github.com/SudoHopeX/KaliGPT.git
  ```

- Move to KaliGPT
  ```
  cd KaliGPT
  ```

- Run the installer to see usages
  ```
  bash kaligpt_unified.sh --help
  ```

- Install a KaliGPT Model
  ```
  sudo bash kaligpt_unified.sh --model <model-number>
  ```
see kaligpt installer usages for more

## KaliGPT Installer Usages
```
KaliGPT Installer ~ SudoHopeX | Krishna Dwivedi
[Contact SudoHopeX](https://sudohopex.github.io/)

KaliGPT Installer Available commands:
   --model <model-num>         -  install a specific model
   --listmodels                -  list available models
   --uninstall-m <model-num>   -  uninstall a specific model
   --uninstall                 -  uninstall KaliGPT (everything)
   --help                      -  print this usage info

KaliGPT Available MODELs:
   1) OpenAI ChatGPT ( OpenAI, Free, Online ) [ requires API KEY ]
   2) Mistral    ( Free, Offline - Min 6GB Data Required)
   3) Llama      ( Free, Offline )
   4) KaliGPT -web based ( OpenAI, Free, Online )
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
  kaligpt [mode] [Prompt (optional)]

MODES: (Must Included)
    -c  -  use ChatGPT-4o (OpenAI, Paid, Online)
    -cw -  use KaliGPT in chromium web browser (OpenAI, Free, Online )
            [ requires 1 time login & keep logged in config on web ]
    -m  -  use Mistral via Ollama (Free, Offline)
    -l  -  use LlaMa via Ollama (Free, Offline)
    -h  -  show this help message and exit

Examples:
     kaligpt -m "How to Scan a website for subdomains using tools"
     kaligpt -l "Help me find XXS on a target.com"
     kaligpt -c
     kaligpt -cw

 NOTE: do not pass prompt with -cw
```

## Switching AI Backends
- You can choose between:
  - **ChatGPT 4.0** (API key required, paid)
  - **Mistral or Llama 3** (local, free, via Ollama)
  - **Web interface** (no key required, but automates browser only for KaliGPT via OpenAI)

## Changing Default Browser for KaliGPT web:
To switch from Chromium to another browser:
1. Open `kaligpt_unified.sh` in a text editor.
2. Find the section referencing `chromium` and comment it
3. Uncomment or add your preferred browser's binary (e.g., `firefox`, `brave-browser`, etc.). 
4. Save and rerun the script.

## License

This project is licensed under the [MIT License](LICENSE).


## Contributing

Pull requests and issues are welcome! Please open an issue to discuss your ideas or report bugs.


## Disclaimer
This script is in testing phase now...
This script is provided with no warranty. Use at your own risk, especially when modifying system binaries or running third-party models.
