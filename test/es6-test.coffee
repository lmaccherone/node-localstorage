{LocalStorage} = require('../')
tape = require('tape')

tape('array and dot notation', (test) =>  # TODO: These tests are inadequate in that it will pass even when there is no Proxy object. Need to check for file existence. 
  localStorage = new LocalStorage('./scratch9')

  localStorage['a'] = 'something'
  test.equal(localStorage['a'], 'something')

  localStorage[''] = 'something else'
  test.equal(localStorage[''], 'something else')

  localStorage.b = 1
  test.equal(localStorage['b'], '1')

  test.deepEqual(Object.keys(localStorage), ['a', '', 'b'])

  localStorage._deleteLocation()
  test.end()
)