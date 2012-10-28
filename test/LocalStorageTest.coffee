{LocalStorage} = require("../")

exports.LocalStorageTest =
  testConstruction: (test) ->
    temp = new LocalStorage('./scratch')
    test.equal(temp.location, './scratch')
    test.done()

