const fs = require('fs');
const https = require('https');
const path = require('path');

// Create assets/fonts directory if it doesn't exist
const fontsDir = path.join(__dirname, '..', 'assets', 'fonts');
if (!fs.existsSync(fontsDir)) {
  fs.mkdirSync(fontsDir, { recursive: true });
}

// Inter font variants to download from Google Fonts
const fontFiles = [
  {
    name: 'Inter-Regular.ttf',
    url: 'https://github.com/google/fonts/raw/main/ofl/inter/Inter%5Bwght%5D.ttf',
  },
  {
    name: 'Inter-Medium.ttf',
    url: 'https://github.com/google/fonts/raw/main/ofl/inter/static/Inter-Medium.ttf',
  },
  {
    name: 'Inter-SemiBold.ttf',
    url: 'https://github.com/google/fonts/raw/main/ofl/inter/static/Inter-SemiBold.ttf',
  },
  {
    name: 'Inter-Bold.ttf',
    url: 'https://github.com/google/fonts/raw/main/ofl/inter/static/Inter-Bold.ttf',
  },
];

// Function to download a file
function downloadFile(url, filePath) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(filePath);
    https.get(url, (response) => {
      if (response.statusCode !== 200) {
        reject(new Error(`Failed to download ${url}: ${response.statusCode}`));
        return;
      }
      response.pipe(file);
      file.on('finish', () => {
        file.close();
        resolve();
      });
    }).on('error', (err) => {
      fs.unlink(filePath, () => {}); // Delete the file if there's an error
      reject(err);
    });
  });
}

// Download all font files
async function downloadFonts() {
  console.log('Downloading Inter font files...');
  
  for (const font of fontFiles) {
    const filePath = path.join(fontsDir, font.name);
    
    // Skip if file already exists
    if (fs.existsSync(filePath)) {
      console.log(`✓ ${font.name} already exists`);
      continue;
    }
    
    try {
      console.log(`Downloading ${font.name}...`);
      await downloadFile(font.url, filePath);
      console.log(`✓ Downloaded ${font.name}`);
    } catch (error) {
      console.error(`Error downloading ${font.name}:`, error.message);
    }
  }
  
  console.log('Font download complete!');
}

downloadFonts().catch(console.error);
