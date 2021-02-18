const contentHash = require('content-hash')
console.log(contentHash.fromIpfs(process.argv[2]))
