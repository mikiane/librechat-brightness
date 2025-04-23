
// util/index.js

// 1. Gestion des erreurs OpenAI
const handleOpenAIErrors = require('./handleOpenAIErrors');

// 2. Import des fonctions de validation et chargement des tools
const { validateTools, loadTools } = require('./handleTools');

// 3. Import des constructeurs d’outils
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
const BrowserScraper         = require('../structured/BrowserScraper'); // ← votre nouvel outil

// 4. Déclaration de la liste des outils disponibles
const availableTools = [
  // … vos autres outils existants, exemple :
  { pluginKey: 'google',            name: 'Google Search',           description: 'Search the web',  icon: null, isAuthRequired: false, authConfig: [] },
  { pluginKey: 'open_weather',      name: 'OpenWeather',             description: 'Weather data',    icon: null, isAuthRequired: false, authConfig: [] },
  // …
  // Et enfin l’entrée pour BrowserScraper :
  {
    pluginKey:   'browser-scraper',
    name:        'Browser Scraper',
    description: 'Scrape HTML from static web pages',
    icon:        'https://example.com/icon.png',
    isAuthRequired: false,
    authConfig:     [],
  },
];

// 5. Déclaration du manifest (mappage clé → métadonnées)
const manifestToolMap = availableTools.reduce((map, tool) => {
  map[tool.pluginKey] = tool;
  return map;
}, {});

// 6. Export de tout ce qui est nécessaire à handleTools.js et au reste de l’app
module.exports = {
  // erreurs & validation
  handleOpenAIErrors,
  validateTools,
  loadTools,
  // listes et manifest
  availableTools,
  manifestToolMap,
  // constructeurs bruts
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
