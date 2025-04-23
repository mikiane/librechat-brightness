const fs = require('fs');
const path = require('path');
const { handleOpenAIErrors, validateTools, loadTools } = require('../utils');

const GoogleSearchAPI        = require('./GoogleSearchAPI');
const DALLE3                 = require('./DALLE3');
const FluxAPI                = require('./FluxAPI');
const OpenWeather            = require('./OpenWeather');
const StructuredSD           = require('./StructuredSD');
const StructuredACS          = require('./StructuredACS');
const TraversaalSearch       = require('./TraversaalSearch');
const StructuredWolfram      = require('./StructuredWolfram');
const { createYouTubeTools } = require('./YouTubeTools');
const TavilySearchResults    = require('./TavilySearchResults');
const BrowserScraper         = require('./structured/BrowserScraper');

const availableTools = [
  { pluginKey: 'google',         name: 'Google Search',           description: 'Search the web',                                          icon: null, isAuthRequired: false, authConfig: [] },
  { pluginKey: 'open_weather',   name: 'OpenWeather',             description: 'Weather data',                                            icon: null, isAuthRequired: false, authConfig: [] },
  // (Insert other existing tool entries here as they were before)
  {
    pluginKey:     'browser-scraper',
    name:          'Browser Scraper',
    description:   'Scrape HTML content from static web pages (no JavaScript rendering).',
    icon:          'https://example.com/icon.png',
    isAuthRequired: false,
    authConfig:     [],
  },
];

const manifestToolMap = availableTools.reduce((map, tool) => {
  map[tool.pluginKey] = tool;
  return map;
}, {});

// existing code here...

module.exports = {
  handleOpenAIErrors,
  validateTools,
  loadTools,
  availableTools,
  manifestToolMap,
  // raw constructors for each tool
  GoogleSearchAPI,
  DALLE3,
  FluxAPI,
  OpenWeather,
  StructuredSD,
  StructuredACS,
  TraversaalSearch,
  StructuredWolfram,
  createYouTubeTools,
  TavilySearchResults,
  BrowserScraper,
};
