#!/usr/bin/env python3

# /agents/gemini.py
# KaliGPT Gemini_agent
# Updated: 26 Jan 2026


from google import genai
from google.genai import types
import sys
import time

from .utils.parse_n_print_response import parse_n_print_response
from .utils.prompts import SYSTEM_PROMPT
from .utils.agent_configs import get_api_key, get_default_model, get_ai_specific_default_model
from .utils.tools import get_tools_info
from .utils.agent_management import agent_management, AI_MANAGEMENT_OPTIONS

# --- GLOBAL VARIABLES ---
GEMINI_API_KEY: str
GEMINI_MODEL: str
TOOLS_INFO: list
client = None
TOOL_FUNCTION_MAP: dict


def initialize_configs():
    global GEMINI_API_KEY, GEMINI_MODEL, client, TOOLS_INFO, TOOL_FUNCTION_MAP
    try:
        GEMINI_API_KEY = get_api_key("gemini")
        GEMINI_MODEL = get_default_model() or get_ai_specific_default_model("gemini")

        if not GEMINI_API_KEY or 'AIza' not in GEMINI_API_KEY:
            print(f"[!] GEMINI API Key not Found. exiting!")
            sys.exit(0)

        # Configure the API for the entire library
        client = genai.Client(api_key=GEMINI_API_KEY)

        # 2. LOAD TOOLS
        TOOLS_INFO = get_tools_info()

        # --- TOOL EXECUTION HELPER (Your Original Function) ---
        TOOL_FUNCTION_MAP = {func.__name__: func for func in TOOLS_INFO} if TOOLS_INFO else {}

        if not TOOLS_INFO:
            print("[!] No external tools loaded.")

    except Exception as e:
        print(f"Failed to initialize Agent: {e}")
        sys.exit(1)


def execute_function_calls(function_calls: list):
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
            result_text = f"Tool {func_name} not found in map!"
        response_parts.append(
            types.Part.from_function_response(name=func_name, response={"result": result_text})
        )
        print(f"[HackerX Tool Use] Tool result ready to send back.")
    return response_parts


def get_gemini_response(history: list[types.Content], new_input: str, tools: list):
    """
    Generates content, including multi-turn tool calling logic, while correctly
    managing history and enabling Chain-of-Thought (CoT) via system_instruction.
    """

    # 1. Start the contents list by incorporating the entire history.
    # The history contains all previous alternating user/model/tool turns.
    contents = history[:]

    # 2. Add the current user input as the new last message.
    # This is the "newest" turn in the conversation.
    contents.append(
        types.Content(role="user", parts=[types.Part.from_text(text=new_input)])
    )

    # 3. Determine the system instruction for the current turn.
    # The system instruction should only be passed once per request, but you pass it
    # for EVERY request to ensure the model *always* has the persona and core rules.
    # NOTE: If you were using the Caching method from earlier, you would use that here instead
    # of the system_instruction parameter. We stick to system_instruction for simplicity here.

    # We use the full system instruction string here.
    current_system_instruction = SYSTEM_PROMPT

    # --- The Multi-Turn Tool Loop ---
    # The entire process (prompt -> tool call -> tool result -> final answer) happens here.
    while True:

        # 4. Call the Model with current contents and config
        response = client.models.generate_content(
            model=GEMINI_MODEL,
            contents=contents,
            config=types.GenerateContentConfig(
                tools=tools,
                # Enable Chain-of-Thought (CoT) support with thinking_budget
                thinking_config=types.ThinkingConfig(thinking_budget=1),
                # Set the primary persona/rules here for every turn
                system_instruction = current_system_instruction
            ),
        )

        # After the first turn, we don't need to re-send the instruction
        # (It's still in the model's short-term memory for the current loop, but not history).
        current_system_instruction = None

        # 5. Check for Function Calls (Simplified check)
        if response.function_calls:

            function_calls = response.function_calls
            function_response_parts = execute_function_calls(function_calls)

            # Append the model's request (FunctionCall) to the contents
            contents.append(response.candidates[0].content)

            # Append the tool's result (FunctionResponse) to the contents
            contents.append(types.Content(role="tool", parts=function_response_parts))

            # Loop continues: The next iteration sends the function results back to the model.
            time.sleep(0.5)
            continue

        # 6. No Function Call -> Final Text Response
        else:
            # Append the final model response to the contents list (History)
            if response.candidates and response.candidates[0].content:
                contents.append(response.candidates[0].content)

            # The updated contents list IS the new chat history.
            new_history = contents

            return response.text, new_history


def main(prompt=None):
    chat_history: list[types.Content] = []

    initialize_configs()   # initialize configs for gemini

    # Print tool banner
    print(f"㉿ HackerX ({GEMINI_MODEL})")
    while True:
        try:
            if prompt is None:
                prompt = input("\nYou ➤ ")


            if prompt.lower().replace("-", " ").strip() in AI_MANAGEMENT_OPTIONS:
                agent_management(prompt.lower().replace("-", " ").strip())
                prompt = None
                continue

            gemini_response, chat_history = get_gemini_response(
                history=chat_history,
                new_input=prompt,
                tools=TOOLS_INFO
            )

            # print(f"\nAgent ➤ ")
            parse_n_print_response(gemini_response)
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
