class ObjectLike
  constructor: (obj) ->
    unless obj?
      obj = {}
    @dummy = obj

    interceptor =
      set: (receiver, key, value) =>
        @dummy[key] = value

      get: (receiver, key) =>
        return @dummy[key]

    return Proxy.create(interceptor, @dummy)

exports.es6ProxyTest =

  theTest: (test) ->
    a = new ObjectLike()
    a['something long'] = 10
    test.equal(a['something long'], 11)
    test.done()