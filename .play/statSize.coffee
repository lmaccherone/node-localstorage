fs = require('fs')

filename = '/Users/larry/.bash_history'
console.log(fs.statSync(filename).size)
file = fs.readFileSync(filename, 'utf8')
console.log(file.length)
