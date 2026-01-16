# File: `agents/__init__.py`
# (create this empty file so `agents` is a package)

# File: `agents/gemini.py` (replace the current utils imports with these)
from .utils.parse_n_print_response import parse_n_print_response
from .utils.prompts import SYSTEM_PROMPT, SYSTEM_PROMPT_OLD
from .utils.agent_configs import get_api_key, get_default_model
from .utils.tools import get_tools_info

# After this change, run from the repo root:
# python -m agents.gemini         ( For Gemini & Google Models )
# python -m agents.openrouter     ( For OpenRouter hosted Models )
# python -m agents.ollama         ( For Locally running Models via Ollama )
