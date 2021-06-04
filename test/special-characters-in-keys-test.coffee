{LocalStorage} = require('../')
tape = require('tape')

tape('use key with asterix', (test) =>
  localStorage = new LocalStorage('./scratch11')

  test.doesNotThrow(() => localStorage.setItem("***test***", 'foo'))

  test.equal(localStorage.getItem('***test***'), 'foo')

  localStorage._deleteLocation()
  test.end()
)
