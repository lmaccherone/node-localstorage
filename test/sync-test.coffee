{LocalStorage} = require('../')
tape = require('tape')

tape('use key with asterix', (test) =>
  storage1 = new LocalStorage('./scratch12')
  storage2 = new LocalStorage('./scratch12')

  test.doesNotThrow(() => storage1.setItem("***test***", 'foo'))
  test.doesNotThrow(() => storage2._sync());
  test.equal(storage2.getItem('***test***'), 'foo')

  storage1._deleteLocation()
  test.end()
)