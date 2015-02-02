{JSONStorage} = require('../')

exports.JSONStorageTest =

  testJSONStorage: (test) ->
    localStorage = new JSONStorage('./scratch')

    test.equal(localStorage.location, './scratch')

    localStorage.setItem('/', 'something')
    test.equal(localStorage.getItem('/'), 'something')
    o = {a:1, b:'some string', c:{x: 1, y: 2}}
    localStorage.setItem('2', o)
    test.deepEqual(localStorage.getItem('2'), o)

    a = [1, 'some string', {a:1, b:'some string', c:{x: 1, y: 2}}]
    localStorage.setItem('2', a)
    test.deepEqual(localStorage.getItem('2'), a)

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

  testNoNewKeyword: (test) ->
    local = JSONStorage('./scratch3')
    local.setItem('Hello', ' world!')
    test.equals(local.getItem('Hello'), ' world!')
    local._deleteLocation()
    test.done()

  testNull: (test) ->
    local = JSONStorage('./scratch4')
    test.equals(local.getItem('junk'), null)
    local._deleteLocation()
    test.done()
