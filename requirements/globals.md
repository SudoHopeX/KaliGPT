[//]: # ( /requirements/global.md )
[//]: # ( SudoHopeX: https://hope.is-a.dev, github.com/SudoHopeX )
[//]: # ( Updated: 28 January 2026 )

# KaliGPT Requirements
This document lists all the requirements/dependencies for KaliGPT, categorized by their source.

## Index
- [GitHub Packages](#github-packages)
- [PyPI (python pip) Packages](#pypi-python-pip-packages)
- [System Packages](#system-packages)
- [Tools](#tools)
- [Love 🩵](#love)


## GitHub Packages
| Package                  | Description                               |
|--------------------------|-------------------------------------------|
| karust/**OpenSerp**      | for performing search queries freely.     |
| SudoHopeX/**KaliGPT** 😉 | for using the KaliGPT itself              |


## PyPI (python pip) Packages
| Package           | Description                          |
|-------------------|--------------------------------------|
| `openai`          | accessing openai & OpenRouter models |
| `google-genai`    | accessing google gemini models       |
| `ollama`          | using ollama models                  |
| `rich`            | for rich text output                 |
| `requests`        | making HTTP requests                 |
| `newspaper3k`     | parsing HTML                         |
| `lxml_html_clean` | cleaning HTML                        |


## System Packages
| Package                                                                  | Description                                                                   | 
|--------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| `curl`                                                                   | Downloading KaliGPT installer scripts                                         |
| `python3`                                                                | Running Python scripts                                                        |
| `python3-venv`                                                           | Managing & using virtual environments                                         | 
| `python3-pip`                                                            | Installing Python dependencies                                                | 
| `git`                                                                    | Cloning GitHub repositories                                                   |
| `golang-go`                                                              | Building & using go based tools (i.e. OpenSerp)                               |
| `bash`                                                                   | Installing KaliGPT, creating & using KaliGPT launcher                         |
| `lixxml2`, `libxslt`                                                     | for building `lxml_html_clean`                                                |
| `libjpeg-turbo`, `libpng`, `freetype`, `littlecms`,`openjpeg`, `libtiff` | for building `Pillow`                                                         | 
| `make`, `pkg-config`, `clang`                                            | building packages like `Pillow`, `lxml`, `lxml_html_clean`, and `newspaper3k` |
| `rust`                                                                   | for building `newspaper3k` dependencies                                       | 


## Tools
| Name                                                         | Description                                                               |
|--------------------------------------------------------------|---------------------------------------------------------------------------|
| `keyword_search`, `check_search_connection`, `search_as_RAG` | for online search & real-time info. connectivity                          |
| `get_local_server_content`                                   | extracting content accessible via local server (e.g. localhost etc.)      |
| `execute_generic_linux_command`                              | executing linux tools & commands                                          |


## Love
Lots of ❤️, Care and ⭐ from the community!
