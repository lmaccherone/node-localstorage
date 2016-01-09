{LocalStorage} = require('../')

exports.SameDirectoryTwiceTest =

  theTest: (test) ->
    localStorage1 = new LocalStorage('./scratch10')
    localStorage2 = new LocalStorage('./scratch10')

    localStorage1.setItem("key1", "value1")

    test.equal(localStorage1.getItem('key1'), localStorage2.getItem('key1'))
       
    localStorage1._deleteLocation()
    test.done()


