#!/usr/bin/env python3

# /agents/chatgpt.py
# KaliGPT ChatGPT_agent
# Updated: 28 Jan 2026


from openai import OpenAI
import sys

from .utils.parse_n_print_response import parse_n_print_response
from .utils.prompts import SYSTEM_PROMPT
from .utils.agent_configs import get_api_key, get_default_model, get_ai_specific_default_model
from .utils.tools import get_tools_info
from .utils.agent_management import agent_management, AI_MANAGEMENT_OPTIONS
from .utils.openai_tool_adapter import openai_tool_adapter


# --- GLOBAL VARIABLES ---
OPENAI_API_KEY: str
OPENAI_MODEL: str
TOOLS_INFO: list
client: OpenAI
TOOL_FUNCTION_MAP: dict



def initialize_configs():
    global OPENAI_API_KEY, OPENAI_MODEL, client, TOOLS_INFO, TOOL_FUNCTION_MAP
    try:
        OPENAI_API_KEY = get_api_key("chatgpt")
        OPENAI_MODEL = get_default_model() or get_ai_specific_default_model("chatgpt")

        if not OPENAI_API_KEY or 'sk-' not in OPENAI_API_KEY:
            print(f"[!] ChatGPT API Key not Found or not valid. exiting!")
            sys.exit(0)

        # Configure the API for the entire library
        client = OpenAI(api_key=OPENAI_API_KEY)

        # 2. LOAD TOOLS info for ChatGPT
        tools = get_tools_info()
        TOOLS_INFO = [openai_tool_adapter(f) for f in tools]

        # --- TOOL EXECUTION HELPER (Your Original Function) ---
        TOOL_FUNCTION_MAP = {func.__name__: func for func in tools} if tools else {}

        if not TOOLS_INFO:
            print("[!] No external tools loaded.")

    except Exception as e:
        print(f"Failed to initialize Agent: {e}")
        sys.exit(1)


MAX_TURNS = 6   # user+assistant pairs

def trim_history(history):
    """ Trim chat history to keep within MAX_TURNS """
    system = [m for m in history if m["role"] == "system"]
    rest = [m for m in history if m["role"] != "system"]
    return system + rest[-MAX_TURNS * 2:]


def get_chatgpt_response(history: list, new_input: str, tools):

    messages = trim_history(history) + [
        {"role": "user", "content": new_input}
    ]

    response = client.responses.create(
        model=OPENAI_MODEL,
        input=messages,
        tools=tools,     # list of tool objects
    )

    tool_calls = [o for o in response.output if o.type == "tool_call"]

    if tool_calls:
        tool_messages = []
        for call in tool_calls:

            if call.name not in TOOL_FUNCTION_MAP:
                result = f"Tool {call.name} not found"
            else:
                result = TOOL_FUNCTION_MAP[call.name](**call.arguments)

            tool_messages.append({
                "role": "tool",
                "tool_call_id": call.id,
                "content": str(result)
            })

        return get_chatgpt_response(
            messages + tool_messages,
            "",
            tools
        )

    # prepare final response
    final_response = "".join(
        o.content[0].text
        for o in response.output
        if o.type == "message"
    )
    # update history
    new_history = messages + [
        {"role": "assistant", "content": final_response}
    ]

    return final_response, new_history


def main(prompt=None):

    # Initialize chat history with system prompt
    chat_history: list = [{"role": "system", "content": SYSTEM_PROMPT}]

    initialize_configs()   # initialize configs for OpenAI ChatGPT

    # Print tool banner
    print(f"㉿ HackerX ({OPENAI_MODEL})")
    while True:
        try:
            if prompt is None:
                prompt = input("\nYou ➤ ")


            if prompt.lower().replace("-", " ").strip() in AI_MANAGEMENT_OPTIONS:
                agent_management(prompt.lower().replace("-", " ").strip())
                prompt = None
                continue

            chatgpt_response, chat_history = get_chatgpt_response(
                history=chat_history,
                new_input=prompt,
                tools=TOOLS_INFO
            )

            # print(f"\nAgent ➤ ")
            parse_n_print_response(chatgpt_response)
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
