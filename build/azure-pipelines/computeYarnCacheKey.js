const fs = require("fs");
const crypto = require("crypto");
const path = require("path");
const { dirs } = require('../../vscode/build/npm/dirs');

const ROOT = path.join(__dirname, '../../vscode');

const shasum = crypto.createHash('sha1');

shasum.update(fs.readFileSync(path.join(ROOT, '.yarnrc')));
shasum.update(fs.readFileSync(path.join(ROOT, 'remote/.yarnrc')));

// Add `yarn.lock` files
for (let dir of dirs) {
    const yarnLockPath = path.join(ROOT, dir, 'yarn.lock');
    shasum.update(fs.readFileSync(yarnLockPath));
}

// Add any other command line arguments
for (let i = 2; i < process.argv.length; i++) {
    shasum.update(process.argv[i]);
}

process.stdout.write(shasum.digest('hex'));
