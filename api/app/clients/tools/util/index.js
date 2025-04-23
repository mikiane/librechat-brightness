const { validateTools, loadTools } = require('./handleTools');
const handleOpenAIErrors = require('./handleOpenAIErrors');

const {
  availableTools,
  manifestToolMap,
  BrowserScraper,
  // Autres outils que vous souhaitez exporter
  // Par exemple :
  // GoogleSearchAPI,
  // DALLE3,
  // ...
} = require('./availableTools'); // Assurez-vous que le chemin est correct

module.exports = {
  handleOpenAIErrors,
  validateTools,
  loadTools,
  availableTools,
  manifestToolMap,
  BrowserScraper,
  // Exportez également les autres outils si nécessaire
  // GoogleSearchAPI,
  // DALLE3,
  // ...
};
