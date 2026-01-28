#!/env/bin/env python3

# /agents/utils/tools/__init__.py
# Updated: 28 Jan 2026

from .openserp_search import check_search_connection, search_as_RAG, keyword_search
from .locals import get_local_server_content, execute_generic_linux_command

def get_tools_info():
    """
    Returns a list of Python functions (tools) that the AI model can use.
    """
    # The list contains the Python function objects themselves!

    return [
        check_search_connection,
        keyword_search,
        search_as_RAG,
        get_local_server_content,
        execute_generic_linux_command
    ]


def get_available_tools_data():
    """
    Returns a dict of tools names with brief description available for the Gemini model.
    """
    _tools = get_tools_info()
    tool_data = {tool.__name__: tool.__doc__.strip().split('\n')[0] if tool.__doc__ else "No description available." for tool in _tools}
    return tool_data

if __name__ == "__main__":
    # print(get_tools_info())
    tools = get_available_tools_data()
    for name, desc in tools.items():
        print(f"◈ {name}: {desc}")
