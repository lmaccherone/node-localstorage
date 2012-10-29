{LocalStorage} = require('../')
fs = require('fs')

exports.LocalStorageTest =

  testFileExists: (test) ->
    fs.writeFileSync('./scratchFile', 'hello', 'utf8')
    f = () ->
      ls2 = new LocalStorage('./scratchFile')
    test.throws(f, Error)
    fs.unlinkSync('./scratchFile')
    test.done()
    