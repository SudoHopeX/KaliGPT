#!/usr/bin/env python3
# /agents/utils/openai_tool_adapter.py
# Updated: 27 Jan 2026

# Tool adapter to convert Python functions to OpenAI function call format for ChatGPT.


import inspect
import typing
from typing import get_origin, get_args
import enum


def python_type_to_json_schema(annotation):
    """Convert Python type annotations to JSON Schema."""
    if annotation is inspect.Parameter.empty:
        return {"type": "string"}

    origin = get_origin(annotation)
    args = get_args(annotation)

    # Optional[T] or Union[T, None]
    if origin is typing.Union and type(None) in args:
        non_none = [a for a in args if a is not type(None)][0]
        return python_type_to_json_schema(non_none)

    # Literal values
    if origin is typing.Literal:
        return {
            "enum": list(args)
        }

    # Enum classes
    if isinstance(annotation, type) and issubclass(annotation, enum.Enum):
        return {
            "type": "string",
            "enum": [e.value for e in annotation]
        }

    # Lists
    if origin in (list, typing.List):
        item_type = args[0] if args else str
        return {
            "type": "array",
            "items": python_type_to_json_schema(item_type)
        }

    # Dicts
    if origin in (dict, typing.Dict):
        return {
            "type": "object",
            "additionalProperties": True
        }

    # Scalars
    if annotation in (str,):
        return {"type": "string"}
    if annotation in (int, float):
        return {"type": "number"}
    if annotation is bool:
        return {"type": "boolean"}

    # Fallback (safe default)
    return {"type": "string"}


def openai_tool_adapter(func):
    sig = inspect.signature(func)

    properties = {}
    required = []

    for name, param in sig.parameters.items():
        schema = python_type_to_json_schema(param.annotation)
        properties[name] = schema

        if param.default is inspect.Parameter.empty:
            required.append(name)

    return {
        "type": "function",
        "function": {
            "name": func.__name__,
            "description": (
                func.__doc__.strip().split("\n")[0]
                if func.__doc__
                else "No description available."
            ),
            "parameters": {
                "type": "object",
                "properties": properties,
                "required": required
            }
        }
    }
