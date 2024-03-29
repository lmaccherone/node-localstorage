{JSONStorage} = require('../')
path = require('path')
tape = require('tape')

tape('JSONStorage', (test) =>
  localStorage = new JSONStorage('./scratch')

  test.equal(localStorage._location, path.resolve('./scratch'))

  localStorage.setItem('/', 'something')
  test.equal(localStorage.getItem('/'), 'something')
  o = {a:1, b:'some string', c:{x: 1, y: 2}}
  localStorage.setItem('2', o)
  test.deepEqual(localStorage.getItem('2'), o)

  a = [1, 'some string', {a:1, b:'some string', c:{x: 1, y: 2}}]
  localStorage.setItem('2', a)
  test.deepEqual(localStorage.getItem('2'), a)

  test.deepEqual(localStorage._keys, ['/', '2'])
  test.equal(localStorage.length, 2)

  localStorage.removeItem('2')
  test.equal(localStorage.getItem('2'), null)

  test.deepEqual(localStorage._keys, ['/'])
  test.equal(localStorage.length, 1)

  test.equal(localStorage.key(0), '/')
  localStorage.clear()
  test.equal(localStorage.length, 0)

  localStorage._deleteLocation()
  test.end()
)

# tape('no new keyword', (test) =>
#   local = JSONStorage('./scratch3')
#   local.setItem('Hello', ' world!')
#   test.equals(local.getItem('Hello'), ' world!')
#   local._deleteLocation()
#   test.end()
# )

tape('null', (test) =>
  local = new JSONStorage('./scratch4')
  test.equals(local.getItem('junk'), null)
  local._deleteLocation()
  test.end()
)