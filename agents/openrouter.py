#!/usr/bin/env python3

# /agents/openrouter.py
# KaliGPT OpenRouter Agent
# Updated: 27 Jan 2026

# Agent to use AI Models via OpenRouter OpenAI API

import sys
import json
from openai import OpenAI

from .utils.agent_configs import get_api_key, get_ai_specific_default_model
from .utils.agent_management import AI_MANAGEMENT_OPTIONS, agent_management
from .utils.parse_n_print_response import parse_n_print_response
from .utils.tools import get_tools_info
from .utils.openai_tool_adapter import openai_tool_adapter
from .utils.prompts import SYSTEM_PROMPT

# ----- Global Variables
OPENROUTER_API_KEY: str
OPENROUTER_MODEL: str
TOOLS_INFO = None
TOOL_FUNCTION_MAP: dict
client: OpenAI

def initialize_agent():
  """Initializes the Tool configs (stored in global variables) like:
        - API KEY
        - AI Model to use for calls
        - Tools information
  """

  global OPENROUTER_API_KEY, OPENROUTER_MODEL, TOOLS_INFO, TOOL_FUNCTION_MAP, client
  try:
    OPENROUTER_API_KEY = get_api_key("openrouter")
    OPENROUTER_MODEL = get_ai_specific_default_model("openrouter")

    if not OPENROUTER_API_KEY or 'sk-or-v1-' not in OPENROUTER_API_KEY:
      print(f"[!] OPENROUTER API Key not Found or not valid. exiting!")
      sys.exit(0)

    tools = get_tools_info()
    TOOLS_INFO = [openai_tool_adapter(f) for f in tools]

    # --- TOOL EXECUTION HELPER (Your Original Function) ---
    TOOL_FUNCTION_MAP = {func.__name__: func for func in tools} if tools else {}

    if not TOOLS_INFO:
      print("[!] No external tools loaded.")

    client = OpenAI(
      base_url="https://openrouter.ai/api/v1",
      api_key=OPENROUTER_API_KEY,
    )

  except Exception as e:
    print(f"Failed to initialize Agent: {e}")
    sys.exit(1)


MAX_TURNS = 6   # user + assistant pairs

def trim_history(history):
    """ Trim chat history to keep within MAX_TURNS """
    system = [m for m in history if m["role"] == "system"]
    rest = [m for m in history if m["role"] != "system"]
    return system + rest[-MAX_TURNS * 2:]

def ask_without_tools(prompt, chat_history):
  """Ask OpenRouter model without tools support."""

  # printing info
  print("[i] The current model doesn't supports tools. Making OpenRouter API call without tools support...")

  # Prepare messages for the API call
  messages = []

  # Add existing chat history if available
  if chat_history:
    messages.extend(trim_history(chat_history))

  # Add the new user message
  messages.append({
    "role": "user",
    "content": prompt
  })

  try:
    # Make the API call without tools support
    completion = client.chat.completions.create(
      model=OPENROUTER_MODEL,
      messages=messages
    )

    # Get the response
    response_msg = completion.choices[0].message

    # Update chat history with assistant messages
    chat_history.append({
      "role": "assistant",
      "content": response_msg.content
    })

    return response_msg.content, chat_history

  except Exception as e:
    # Handle API errors
    error_response = f"API Error: {str(e)}"
    chat_history.append({
      "role": "assistant",
      "content": error_response
    })
    return error_response, chat_history


def ask(prompt, chat_history,  tools=TOOLS_INFO):
  """Ask OpenRouter model with tools support."""

  # Prepare messages for the API call
  messages = []

  # Add existing chat history if available
  if chat_history:
    messages.extend(trim_history(chat_history))

  # Add the new user message
  messages.append({
    "role": "user",
    "content": prompt
  })

  try:
    # Make the API call with tools support
    completion = client.chat.completions.create(
      extra_headers={
        "HTTP-Referer": "HackerX (KaliGPT v1.3)", # Optional. Site URL for rankings on openrouter.ai.
        "X-Title": "https://github.com/SudoHopeX/KaliGPT", # Optional. Site title for rankings on openrouter.ai.
      },
      extra_body={},
      model=OPENROUTER_MODEL,
      messages=messages,
      tools=tools,
      tool_choice="auto" if tools else "none"
    )

    # Get the response
    response_msg = completion.choices[0].message

    # Update chat history with user message
    chat_history.append({
      "role": "user",
      "content": prompt
    })

    # Handle tool calls if present
    if hasattr(response_msg, 'tool_calls') and response_msg.tool_calls:
      # Add assistant message with tool calls to history
      chat_history.append({
        "role": "assistant",
        "content": None,
        "tool_calls": response_msg.tool_calls
      })

      for tool_call in response_msg.tool_calls:
        name = tool_call.function.name
        try:
          tool_args = json.loads(tool_call.function.arguments)
        except Exception as e:
          print(f"[!] Error parsing tool arguments: {e}")
          tool_args = {}

        tool_fn = TOOL_FUNCTION_MAP.get(name)

        if not tool_fn:
          result = f"Tool '{name}' not found"
        else:
          try:
            result = tool_fn(**tool_args)
          except Exception as e:
            result = f"Tool error: {e}"

        chat_history.append({
          "role": "tool",
          "tool_call_id": tool_call.id,
          "content": str(result)
        })

      follow_up = client.chat.completions.create(
        model=OPENROUTER_MODEL,
        messages=trim_history(chat_history),
        tools=tools,
        tool_choice="auto"
      )

      response_msg = follow_up.choices[0].message

    # Add final assistance response to chat history
    if response_msg.content:
      chat_history.append({
          "role": "assistant",
          "content": response_msg.content
      })

      return response_msg.content, chat_history

  except Exception as e:
    # Handle API errors
    error_response = f"API Error: {str(e)}"

    if "'No endpoints found that support tool use" in error_response:
        return ask_without_tools(prompt, chat_history)

    chat_history.append({
      "role": "assistant",
      "content": error_response
    })
    return error_response, chat_history


def main(prompt=None):

  initialize_agent()

  # Initialize chat history with system prompt
  chat_history: list = [{"role": "system", "content": SYSTEM_PROMPT}]

  print(f"㉿ HackerX ('{OPENROUTER_MODEL}')")

  while True:
    try:
      if prompt is None:
        prompt = input("\nYou ➤ ")

      if prompt.lower().replace("-", " ").strip() in AI_MANAGEMENT_OPTIONS:
        agent_management(prompt.lower().replace("-", " ").strip())
        prompt = None
        continue

      response, chat_history = ask(
        chat_history=chat_history,
        prompt=prompt,
        tools=TOOLS_INFO
      )

      # print(f"\nAgent ➤ ")
      parse_n_print_response(response)
      prompt = None

    except KeyboardInterrupt:
      print("\n   Exiting HackerX. See you later!")
      break

    except Exception as err:
      print(f"\n   [!] An error occurred: {err}")


if __name__ == "__main__":
  if len(sys.argv) > 1:
    args = ' '.join(sys.argv[1:])
    main(args)
  else:
    main()
