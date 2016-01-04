{LocalStorage} = require('../')

exports.es6Test =

  theTest: (test) ->
    localStorage = new LocalStorage('./scratch')

    localStorage['a'] = 'something'
    test.equal(localStorage['a'], 'something')

    localStorage[''] = 'something else'
    test.equal(localStorage[''], 'something else')

    localStorage._deleteLocation()
    test.done()