class ArrayLike
  constructor: (array) ->
    unless array?
      array = []
    @dummy = array

    interceptor = {
      set: (receiver, index, value) ->
        dummy[index] = value

      get: (receiver, index) ->
        index = parseInt(index)
        if index < 0
          return dummy[dummy.length + index]
        else
          return dummy[index]
    }
    return Proxy(@dummy, interceptor)

a = new ArrayLike()
a['a'] = 1
console.log(a)