const fs = require('fs');
const path = require('path');

const indexPath = path.join(__dirname, '../build/web/index.html');
const apiUrl = process.env.API_URL || 'https://default-api-url.com';

let indexContent = fs.readFileSync(indexPath, 'utf8');
indexContent = indexContent.replace('__API_URL__', apiUrl);
fs.writeFileSync(indexPath, indexContent);
