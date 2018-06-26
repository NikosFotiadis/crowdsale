const path = require('path');
const fs = require('fs');
const solc = require('solc');

const inboxPath = path.resolve(__dirname, 'contracts', 'crowdsale.sol');

const source = fs.readFileSync(inboxPath, 'utf8');

// console.log(solc.compile(source, 1).contracts[':ERC20NikosToken']);
// console.log(solc.compile(source, 1).contracts[':ErcTokenFON']);
module.exports = solc.compile(source, 1).contracts[':Crowdsale'];
