{LocalStorage} = require('../')

repeat = (string, count) ->
  a = []
  while count--
    a.push(string)
  return a.join('')

exports.LocalStorageTest =

  testLocalStorage: (test) ->
    localStorage = new LocalStorage('./scratch')

    test.equal(localStorage.location, './scratch')
    
    
    localStorage.setItem('/', 'something')
    test.equal(localStorage.getItem('/'), 'something')
    o = {a:1, b:'some string', c:{x: 1, y: 2}}
    localStorage.setItem('2', o)
    test.deepEqual(localStorage.getItem('2'), o.toString())

    a = [1, 'some string', {a:1, b:'some string', c:{x: 1, y: 2}}]
    localStorage.setItem('2', a)
    test.deepEqual(localStorage.getItem('2'), a.toString())
    
    test.deepEqual(localStorage.keys, ['/', '2'])
    test.equal(localStorage.length, 2)

    localStorage.removeItem('2')
    test.equal(localStorage.getItem('2'), null)
    
    test.deepEqual(localStorage.keys, ['/'])
    test.equal(localStorage.length, 1)
    
    test.equal(localStorage.key(0), '/')
    localStorage.clear()
    test.equal(localStorage.length, 0)
       
    localStorage._deleteLocation()
    test.done()

  testQuota: (test) ->
    n10 = '01234567890'
    n100 = repeat('0123456789', 10)
    n1000 = repeat(n100, 10)
    n10000 = repeat(n1000, 10)

    ls = new LocalStorage('./scratch2', 3000)
    ls.setItem(1, n1000)
    ls.setItem(2, n1000)
    ls.setItem(3, n1000)
    test.equal(ls.getBytesInUse(), 3000)

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
    test.done()