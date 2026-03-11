const fs = require('fs');
const path = require('path');
const { Resvg } = require('@resvg/resvg-js');

const inputDir = '../assets/weather_icons/svg';
const outputDir = './output';

// Ensure output directory exists
if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir);
}

// Process all files in the directory
fs.readdirSync(inputDir).forEach(file => {
    if (path.extname(file) === '.svg') {
        const inputPath = path.join(inputDir, file);
        const outputPath = path.join(outputDir, file.replace('.svg', '.png'));

        const svg = fs.readFileSync(inputPath);

        // Configure rendering: 1024x1024 target, preserving aspect ratio
        const resvg = new Resvg(svg, {
            fitTo: {
                mode: 'width',
                value: 128,
            },
        });

        const pngData = resvg.render();
        fs.writeFileSync(outputPath, pngData.asPng());
        console.log(`Generated high-res: ${file}`);
    }
});