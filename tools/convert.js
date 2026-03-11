const fs = require('fs');
const path = require('path');
const svg2img = require('svg2img');

const inputDir = '../assets/weather_icons/svg';
const outputDir = './output';

if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir);

fs.readdirSync(inputDir).forEach(file => {
    if (path.extname(file) === '.svg') {
        const inputPath = path.join(inputDir, file);
        const outputPath = path.join(outputDir, file.replace('.svg', '.png'));

        const svgContent = fs.readFileSync(inputPath, 'utf8');

        // Render at high resolution (1024x1024)
        svg2img(svgContent, { 'width': 1024, 'height': 1024 }, function (error, buffer) {
            if (error) {
                console.error(`Error converting ${file}:`, error);
                return;
            }
            fs.writeFileSync(outputPath, buffer);
            console.log(`Successfully generated: ${outputPath}`);
        });
    }
});