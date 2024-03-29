{LocalStorage} = require('../')
path = require('path')
tape = require('tape')

repeat = (string, count) ->
  a = []
  while count--
    a.push(string)
  return a.join('')

tape('localStorage API', (test) =>
  localStorage = new LocalStorage('./scratch')

  test.equal(localStorage._location, path.resolve('./scratch'))
  
  localStorage.setItem('/', 'something')
  test.equal(localStorage.getItem('/'), 'something')
  o = {a:1, b:'some string', c:{x: 1, y: 2}}
  localStorage.setItem('2', o)
  test.deepEqual(localStorage.getItem('2'), o.toString())

  a = [1, 'some string', {a:1, b:'some string', c:{x: 1, y: 2}}]
  localStorage.setItem('2', a)
  test.deepEqual(localStorage.getItem('2'), a.toString())
  
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

tape('quota', (test) =>
  n10 = '01234567890'
  n100 = repeat('0123456789', 10)
  n1000 = repeat(n100, 10)
  n10000 = repeat(n1000, 10)

  ls = new LocalStorage('./scratch2', 3000)
  ls.setItem(1, n1000)
  ls.setItem(2, n1000)
  ls.setItem(3, n1000)
  test.equal(ls._getBytesInUse(), 3000)

  f = () ->
    ls.setItem(6, n10)

  test.throws(f, Error)
  ls.setItem(2, n1000)  # Should not throw because it replaces one of equal size

  ls.removeItem(3)
  ls.setItem(7, n100)
  f2 = () ->
    ls.setitem(8, n1000)
  test.throws(f2, Error)

  ls._deleteLocation()
  test.end()
)

# tape('no new keyword', (test) =>
#   local = LocalStorage('./scratch3')
#   local.setItem('Hello', ' world!')
#   test.equals(local.getItem('Hello'), ' world!')
#   local._deleteLocation()
#   test.end()
# )

tape('null', (test) =>
  local = new LocalStorage('./scratch4')
  test.equals(local.getItem('junk'), null)
  local._deleteLocation()
  test.end()
)

tape('remove keys', (test) =>
  localStorage = new LocalStorage('./scratch6');

  localStorage.setItem('a', 'hello')
  localStorage.setItem('b', 'hello')
  localStorage.setItem('c', 'hello')
  localStorage.setItem('d', 'hello')

  test.deepEqual(localStorage._keys, ['a', 'b', 'c', 'd'])
  test.deepEqual(Object.keys(localStorage), ['a', 'b', 'c', 'd'])
  localStorage.removeItem('c')
  test.deepEqual(localStorage._keys, ['a', 'b', 'd'])
  localStorage.removeItem('a');
  test.deepEqual(localStorage._keys, ['b', 'd'])
  localStorage.removeItem('b')
  test.deepEqual(localStorage._keys, ['d'])
  localStorage.removeItem('d')
  test.deepEqual(localStorage._keys, [])
  test.deepEqual(Object.keys(localStorage), [])

  localStorage._deleteLocation()
  test.end()
)

tape('events', (test) =>
  localStorage = new LocalStorage('./scratch5')

  expectedUrl = "pid:" + process.pid
  key = null; oldVal = null; newVal = null; url = null
  handleEvent = (evnt) ->
    key = evnt.key
    oldVal = evnt.oldValue
    newVal = evnt.newValue
    url = evnt.url

  localStorage.on('storage', handleEvent)
  
  localStorage.setItem('a', 'something')
  test.equal(localStorage.getItem('a'), 'something')
  test.equal(key, 'a')
  test.equal(oldVal, null)
  test.equal(newVal, 'something')
  test.equal(url, expectedUrl)

  key = null; oldVal = null; newVal = null; url = null
  localStorage.setItem('a', 'somethingnew')
  test.equal(localStorage.getItem('a'), 'somethingnew')
  test.equal(key, 'a')
  test.equal(oldVal, 'something')
  test.equal(newVal, 'somethingnew')
  test.equal(url, expectedUrl)
  
  key = null; oldVal = null; newVal = null; url = null
  localStorage.removeItem('a')
  test.equal(localStorage.getItem('a'), null)
  test.equal(key, 'a')
  test.equal(oldVal, 'somethingnew')
  test.equal(newVal, null)
  test.equal(url, expectedUrl)

  key = null; oldVal = null; newVal = null; url = null
  localStorage.clear();
  test.equal(localStorage.getItem('a'), null)
  test.equal(key, null)
  test.equal(oldVal, null)
  test.equal(newVal, null)
  test.equal(url, expectedUrl)
  
  localStorage._deleteLocation()
  test.end()
)

tape('get stat', (test) =>
  localStorage = new LocalStorage('./scratch7')

  o = {a:1, b:'some string', c:{x: 1, y: 2}}
  localStorage.setItem('stat', o)
  test.deepEqual(localStorage.getItem('stat'), o.toString())

  test.ok(localStorage._getStat('stat')?)
  test.equal(localStorage._getStat('not there'), null)

  localStorage._deleteLocation()
  test.end()
)

tape('empty string', (test) =>
  localStorage = new LocalStorage('./scratch8')

  localStorage.setItem('', 'something')
  test.equal(localStorage.getItem(''), 'something')

  test.equal(localStorage.key(0), '')

  localStorage._deleteLocation()
  test.end()
)

