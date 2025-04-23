from mcp.server.fastmcp import FastMCP
import httpx
from playwright.async_api import async_playwright

# Instanciation avec host, port et log_level (en MAJUSCULES)
mcp = FastMCP(
    name="ScraperServer",
    host="0.0.0.0",
    port=27124,
    log_level="INFO"     # ← mettre INFO, pas "info"
)

@mcp.tool()
async def fetch_page(url: str) -> str:
    async with httpx.AsyncClient() as client:
        response = await client.get(url)
        return response.text

@mcp.tool()
async def fetch_page_js(url: str) -> str:
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        page = await browser.new_page()
        await page.goto(url)
        content = await page.content()
        await browser.close()
        return content

if __name__ == "__main__":
    # Démarrage du serveur SSE sans passer de paramètres réseau,
    # ceux-ci étant déjà fixés dans le constructeur
    mcp.run(transport="sse")
