{LocalStorage} = require('../')
tape = require('tape')

tape('use key without toString', (test) =>
  localStorage = new LocalStorage('./scratch11')

  test.doesNotThrow(() => localStorage.setItem(null, 'foo'))
  test.doesNotThrow(() => localStorage.setItem(undefined, 'bar'))

  test.equal(localStorage.getItem('null'), 'foo')
  test.equal(localStorage.getItem('undefined'), 'bar')

  localStorage._deleteLocation()
  test.end()
)

tape('set value without toString', (test) =>
  localStorage = new LocalStorage('./scratch12')

  test.doesNotThrow(() => localStorage.setItem('foo', null))
  test.doesNotThrow(() => localStorage.setItem('bar', undefined))

  test.equal(localStorage.getItem('foo'), 'null')
  test.equal(localStorage.getItem('bar'), 'undefined')

  localStorage._deleteLocation()
  test.end()
)