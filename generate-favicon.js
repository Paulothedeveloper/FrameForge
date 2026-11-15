#!/usr/bin/env node
/**
 * Favicon Generator for FrameForge
 * Generates multi-resolution ICO file from SVG logo
 * 
 * Uses sharp library (install with: npm install sharp)
 */

const fs = require('fs');
const path = require('path');

console.log('🎨 FrameForge Favicon Generator');
console.log('================================\n');

// Check if sharp is available
let sharp;
try {
    sharp = require('sharp');
} catch (err) {
    console.log('⚠️  Sharp not found. Installing...\n');
    const { execSync } = require('child_process');
    execSync('npm install sharp --no-save', { stdio: 'inherit' });
    sharp = require('sharp');
}

const svgPath = path.join(__dirname, 'branding/final/frameforge-icon.svg');
const outputPath = path.join(__dirname, 'favicon.ico');

// Read SVG
const svgBuffer = fs.readFileSync(svgPath);

// Generate PNG at different sizes for ICO
const sizes = [16, 32, 48, 64];
const promises = sizes.map(size => 
    sharp(svgBuffer)
        .resize(size, size)
        .png()
        .toBuffer()
);

Promise.all(promises)
    .then(buffers => {
        console.log('✅ Generated PNG buffers for sizes:', sizes.join(', '));
        
        // Create ICO file (multi-resolution)
        // ICO header: Reserved(2) + Type(2) + Count(2) = 6 bytes
        const count = buffers.length;
        const header = Buffer.alloc(6);
        header.writeUInt16LE(0, 0);  // Reserved
        header.writeUInt16LE(1, 2);  // Type: 1 = ICO
        header.writeUInt16LE(count, 4);  // Count of images
        
        // ICO directory entries: 16 bytes each
        const entries = Buffer.alloc(16 * count);
        let dataOffset = 6 + (16 * count);
        
        buffers.forEach((buffer, i) => {
            const size = sizes[i];
            const offset = i * 16;
            
            entries.writeUInt8(size === 256 ? 0 : size, offset + 0);  // Width
            entries.writeUInt8(size === 256 ? 0 : size, offset + 1);  // Height
            entries.writeUInt8(0, offset + 2);  // Color palette (0 = no palette)
            entries.writeUInt8(0, offset + 3);  // Reserved
            entries.writeUInt16LE(1, offset + 4);  // Color planes
            entries.writeUInt16LE(32, offset + 6);  // Bits per pixel
            entries.writeUInt32LE(buffer.length, offset + 8);  // Size in bytes
            entries.writeUInt32LE(dataOffset, offset + 12);  // Offset in file
            
            dataOffset += buffer.length;
        });
        
        // Concatenate: header + entries + all image data
        const ico = Buffer.concat([header, entries, ...buffers]);
        fs.writeFileSync(outputPath, ico);
        
        console.log(`✅ Favicon saved: ${outputPath}`);
        console.log(`   Sizes: ${sizes.join('x, ')}x pixels`);
        console.log(`   Total size: ${(ico.length / 1024).toFixed(2)} KB`);
        console.log('\n🎉 Done! Add to your HTML:');
        console.log('   <link rel="icon" href="favicon.ico" type="image/x-icon">');
    })
    .catch(err => {
        console.error('❌ Error:', err.message);
        process.exit(1);
    });
