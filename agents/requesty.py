#!/usr/bin/env python3

# /agents/requesty.py
# KaliGPT Requesty Agent
# Updated: 24 feb 2026

# Agent to use AI Models via Requesty OpenAI-compatible API

import sys
import json
from openai import OpenAI

from .utils.agent_configs import get_api_key, get_ai_specific_default_model
from .utils.agent_management import AI_MANAGEMENT_OPTIONS, agent_management
from .utils.parse_n_print_response import parse_n_print_response
from .utils.tools import get_tools_info
from .utils.openai_tool_adapter import openai_tool_adapter
from .utils.prompts import WEB_BUG_BOUNTY_AGENT as SYSTEM_PROMPT

# ----- Global Variables
REQUESTY_API_KEY: str
REQUESTY_MODEL: str
TOOLS_INFO = None
TOOL_FUNCTION_MAP: dict
client: OpenAI

def initialize_agent():
  """Initializes the Tool configs (stored in global variables) like:
        - API KEY
        - AI Model to use for calls
        - Tools information
  """

  global REQUESTY_API_KEY, REQUESTY_MODEL, TOOLS_INFO, TOOL_FUNCTION_MAP, client
  try:
    REQUESTY_API_KEY = get_api_key("requesty")
    REQUESTY_MODEL = get_ai_specific_default_model("requesty")

    if not REQUESTY_API_KEY or REQUESTY_API_KEY == "YOUR_REQUESTY_API_KEY":
      print(f"[!] REQUESTY API Key not Found or not valid. exiting!")
      sys.exit(0)

    tools = get_tools_info()
    TOOLS_INFO = [openai_tool_adapter(f) for f in tools]

    # --- TOOL EXECUTION HELPER (Your Original Function) ---
    TOOL_FUNCTION_MAP = {func.__name__: func for func in tools} if tools else {}

    if not TOOLS_INFO:
      print("[!] No external tools loaded.")

    client = OpenAI(
      base_url="https://router.requesty.ai/v1",
      api_key=REQUESTY_API_KEY,
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


def execute_tool_calls(tool_calls):
    """Executes tools and returns a list of OpenAI-formatted 'tool' messages."""
    tool_messages = []

    for tool_call in tool_calls:
        func_name = tool_call.function.name
        call_id = tool_call.id

        try:
            func_args = json.loads(tool_call.function.arguments)
            print(f"\n[HackerX Tool Use] name: {func_name}, args: {func_args}")
        except Exception as e:
            print(f"[!] Error parsing tool arguments: {e}")
            func_args = {}

        tool_fn = TOOL_FUNCTION_MAP.get(func_name)
        if not tool_fn:
            result = f"Error: Tool '{func_name}' not found"
        else:
            try:
                result = tool_fn(**func_args)
            except Exception as e:
                result = f"Tool execution error: {e}"

        # Correct OpenAI/Requesty Tool Message format
        tool_messages.append({
            "role": "tool",
            "tool_call_id": call_id,
            "name": func_name,
            "content": str(result)
        })

    return tool_messages


def ask(prompt, chat_history, tools=TOOLS_INFO):
    """Ask Requesty model with recursive tool support and proper history."""

    # Add the user message to the working set (don't append to persistent history yet)
    messages = trim_history(chat_history) + [{"role": "user", "content": prompt}]

    try:
        # Step 1: Initial Request
        completion = client.chat.completions.create(
            model=REQUESTY_MODEL,
            messages=messages,
            tools=tools,
            tool_choice="auto" if tools else "none"
        )

        response_msg = completion.choices[0].message

        # Step 2: Tool Handling Loop (Handles nested/parallel calls)
        while response_msg.tool_calls:
            # Add the model's request to call tools to the history
            messages.append(response_msg)

            # Execute tools and get "tool" role messages
            tool_results = execute_tool_calls(response_msg.tool_calls)
            messages.extend(tool_results)

            # Get the follow-up from the model
            follow_up = client.chat.completions.create(
                model=REQUESTY_MODEL,
                messages=messages,
                tools=tools
            )
            response_msg = follow_up.choices[0].message

        # Step 3: Finalize History
        final_text = response_msg.content or ""

        # Update the actual history object for the next turn
        chat_history.append({"role": "user", "content": prompt})
        chat_history.append({"role": "assistant", "content": final_text})

        return final_text, chat_history

    except Exception as e:
        error_msg = f"API/Logic Error: {str(e)}"
        # print(f"[!] {error_msg}")

        if "No endpoints found that support tool use" in error_msg:
            completion = client.chat.completions.create(
                model=REQUESTY_MODEL,
                messages=messages,
            )

            response = completion.choices[0].message
            chat_history.append({"role": "assistant", "content": response.content})

            return response.content, chat_history

        return error_msg, chat_history  # Ensures we always return a tuple


def main(prompt=None):

  initialize_agent()

  # Initialize chat history with system prompt
  chat_history: list = [{"role": "system", "content": SYSTEM_PROMPT}]

  print(f"㉿ HackerX ( requesty/{REQUESTY_MODEL} )")

  while True:
    try:
      if prompt is None:
        prompt = input("\nYou ➤ ")

      if prompt.lower().replace("-", " ").strip() in AI_MANAGEMENT_OPTIONS:
        agent_management(prompt.lower().replace("-", " ").strip())
        initialize_agent()
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
      break


if __name__ == "__main__":
  if len(sys.argv) > 1:
    args = ' '.join(sys.argv[1:])
    main(args)
  else:
    main()
