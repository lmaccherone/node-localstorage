{LocalStorage} = require('../')
fs = require('fs')
tape = require('tape')

tape('file exists error', (test) =>
  fs.writeFileSync('./scratchFile', 'hello', 'utf8')
  f = () ->
    ls2 = new LocalStorage('./scratchFile')
  test.throws(f, Error)
  fs.unlinkSync('./scratchFile')
  test.end()
)