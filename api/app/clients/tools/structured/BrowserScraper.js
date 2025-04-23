const { Tool } = require('langchain/tools');
const axios = require('axios');

class BrowserScraper extends Tool {
  constructor(fields) {
    super();
    this.name = 'browser-scraper';
    this.description = 'Scrape HTML content from static web pages (no JavaScript rendering).';
  }

  async _call(url) {
    try {
      const response = await axios.get(url);
      return response.data.slice(0, 4000); // évite les réponses trop longues
    } catch (error) {
      return `Erreur lors du scraping : ${error.message}`;
    }
  }
}

module.exports = BrowserScraper;
