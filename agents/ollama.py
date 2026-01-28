#!/usr/bin/env python3

# kaligpt Ollama Agent
# /agent/ollama.py
# Updated: 28 January 2026


import sys
import types
from ollama import chat, ChatResponse

from .utils.parse_n_print_response import parse_n_print_response
from .utils.prompts import SYSTEM_PROMPT
from .utils.agent_configs import get_default_model, get_ai_specific_default_model, get_api_key
from .utils.tools import get_tools_info
from .utils.agent_management import AI_MANAGEMENT_OPTIONS, agent_management
from .utils.openai_tool_adapter import openai_tool_adapter


# --- GLOBAL VARIABLES ---
OLLAMA_API_URL: str   # OLLAMA API URL as OLLAMA_API_KEY
OLLAMA_MODEL: str
TOOLS_INFO: list
TOOL_FUNCTION_MAP: dict
print_msg: bool

def initialize_configs():
    global OLLAMA_API_URL, OLLAMA_MODEL, TOOLS_INFO, TOOL_FUNCTION_MAP, print_msg
    try:
        OLLAMA_API_URL = get_api_key("ollama")
        OLLAMA_MODEL = get_ai_specific_default_model("ollama")
        tools = get_tools_info()
        TOOLS_INFO = [openai_tool_adapter(f) for f in tools]

        if not TOOLS_INFO:
            print("[!] No external tools loaded.")

        # --- TOOL EXECUTION HELPER (Your Original Function) ---
        TOOL_FUNCTION_MAP = {func.__name__: func for func in tools} if tools else {}

        # print that tool doesn't support's thinking or tool_calls
        print_msg = True
    except Exception as e:
        print(f"Failed to initialize Ollama Agent: {e}")
        sys.exit(1)


MAX_TURNS = 6   # user+assistant pairs

def trim_history(history):
    """ Trim chat history to keep within MAX_TURNS """
    system = [m for m in history if m["role"] == "system"]
    rest = [m for m in history if m["role"] != "system"]
    return system + rest[-MAX_TURNS * 2:]


def execute_function_calls(function_calls):
    response_parts = []
    print("\n[HackerX Tool Use] Owo! I found a tool I need to run! <3")

    for call in function_calls:
        func_name = call.name
        func_args = dict(call.args)

        if func_name in TOOL_FUNCTION_MAP:
            print(f"[HackerX Tool Use] Running tool: {func_name} with args: {func_args}")
            try:
                result_text = TOOL_FUNCTION_MAP[func_name](**func_args)
            except Exception as e:
                result_text = f"Tool execution failed with error: {e}"
        else:
            result_text = f"Tool {func_name} not found!"

        response_parts.append(
            types.Part.from_function_response(name=func_name, response={"result": result_text})
        )

    return response_parts


# getting response from ollama model with tool calling Agent Loop
def ask(user_input, history, tools):

    messages = trim_history(history) + [
        {"role": "user", "content": user_input}
    ]

    while True:
        try:
            response: ChatResponse = chat(
                model=OLLAMA_MODEL,
                messages=messages,
                tools=tools,
                think=True
            )
        except:
            global print_msg
            if print_msg:
                print("[!] Thinking or Tool call disabled for this model (Check it's documentation)\n")
                print_msg = False
            response: ChatResponse = chat(
                model=OLLAMA_MODEL,
                messages=messages
            )

        messages.append({"role": "assistant", "content": str(response.message.content)})

        if response.message.tool_calls:
            tool_result = execute_function_calls(response.message.tool_calls)

            # continue the loop with the updated messages
            messages.append({"role": "tool", "content": str(tool_result)})

        else:
            break

    response_text = response.message.content
    new_history = messages

    return response_text, new_history


def main(prompt=None):

    # Initialize chat history with system prompt
    chat_history: list = [{"role": "system", "content": SYSTEM_PROMPT}]

    initialize_configs()   # initialize configs for Ollama

    # Print tool banner
    print(f"㉿ HackerX ( '{OLLAMA_MODEL}' )")
    while True:
        try:
            if prompt is None:
                prompt = str(input("\nYou ➤ "))

            if prompt.lower().replace("-", " ").strip() in AI_MANAGEMENT_OPTIONS:
                agent_management(prompt.lower().replace("-", " ").strip())
                initialize_configs()
                prompt = None
                continue

            response, chat_history = ask(
                history=chat_history,
                user_input=prompt,
                tools=TOOLS_INFO
            )

            # print(f"\nAgent ➤ ")
            parse_n_print_response(response)
            prompt = None

        except KeyboardInterrupt:
            print("\n   Exiting HackerX. See you later!")
            break

        except Exception as err:
            print(f"\n[!] An error occurred: {err}")
            break

if __name__ == "__main__":
    if len(sys.argv) > 1:
        args = ' '.join(sys.argv[1:])
        main(args)
    else:
        main()
