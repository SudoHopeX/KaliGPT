#!/env/bin/env python3

# /agents/utils/tools/scraping.py
# Updated: 26 Jan 2026


import requests
from bs4 import BeautifulSoup


def get_local_server_content(url: str, timeout: int = 5) -> dict[str, bool | None | str] | dict[
    str, bool | int | str | None]:
    """
    Fetch and extract readable text content from a local server webpage.
    Returns structured status instead of raising exceptions.

    Args:
        url (str): The URL of the local server webpage to scrape.
        timeout (int): Timeout for the HTTP request in seconds. (default = 5)

    Returns:
        dict -> {  status: bool (True, False),
                    status_code: int | None,
                    error: str | None,
                    content: str | None
                    }
    """

    try:
        response = requests.get(
            url,
            timeout=timeout,
            headers={"User-Agent": "LocalScraper/1.0"}
        )
    except requests.RequestException as exc:
        return {
            "success": False,
            "status_code": None,
            "error": str(exc),
            "content": None
        }

    if response.status_code != 200:
        return {
            "success": False,
            "status_code": response.status_code,
            "error": f"HTTP {response.status_code}",
            "content": None
        }

    soup = BeautifulSoup(response.content, "html.parser")

    for tag in soup(["script", "style", "noscript", "header", "footer", "nav"]):
        tag.decompose()

    text = soup.get_text(separator="\n", strip=True)

    return {
        "success": True,
        "status_code": response.status_code,
        "error": None,
        "content": text
    }


if __name__ == "__main__":
    result = get_local_server_content("https://example.com")

    if result["success"]:
        print(result["content"][:500])
    else:
        print(f"Error: {result['error']} (status={result['status_code']})")
