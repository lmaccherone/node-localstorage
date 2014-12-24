path = require('path')
fs = require('fs')

_emptyDirectory = (target) ->
  _rm(path.join(target, p)) for p in fs.readdirSync(target)

_rm = (target) ->
  if fs.statSync(target).isDirectory()
    _emptyDirectory(target)
    fs.rmdirSync(target)
  else
    fs.unlinkSync(target)

class QUOTA_EXCEEDED_ERR extends Error
  constructor: (@message = 'Unknown error.') ->
    if Error.captureStackTrace?
      Error.captureStackTrace(this, @constructor)
    @name = @constructor.name

  toString: () ->
    return "#{@name}: #{@message}"

class LocalStorage

  constructor: (@location, @quota = 5 * 1024 * 1024) ->
    unless this instanceof LocalStorage
      return new LocalStorage(@location, @quota)
    @length = 0  # !TODO: Maybe change this to a property with __defineProperty__
    @bytesInUse = 0
    @keys = []
    @_init()
    @QUOTA_EXCEEDED_ERR = QUOTA_EXCEEDED_ERR
  
  _init: () ->
    if fs.existsSync(@location)
      unless fs.statSync(@location).isDirectory()
        throw new Error("A file exists at the location '#{@location}' when trying to create/open localStorage")
    unless fs.existsSync(@location)
      fs.mkdirSync(@location)
    @keys = fs.readdirSync(@location).map(decodeURIComponent)
    @length = @keys.length
    @bytesInUse = 0
    for k in @keys
      value = @getItem(k)
      if value?.length?
        @bytesInUse += value.length

  setItem: (key, value) ->
    key = key.toString()
    filename = path.join(@location, encodeURIComponent(key))
    existsBeforeSet = fs.existsSync(filename)
    valueString = value.toString()
    valueStringLength = valueString.length
    if existsBeforeSet
      oldLength = @getItem(key).length
    else
      oldLength = 0
    if @bytesInUse - oldLength + valueStringLength > @quota
      throw new QUOTA_EXCEEDED_ERR()
    fs.writeFileSync(filename, valueString, 'utf8')
    unless existsBeforeSet
      @keys.push(key)
      @length = @keys.length
      @bytesInUse += valueStringLength

  getItem: (key) ->
    key = key.toString()
    filename = path.join(@location, encodeURIComponent(key))
    if fs.existsSync(filename)
      return fs.readFileSync(filename, 'utf8')
    else
      return null
  
  removeItem: (key) ->
    key = key.toString()
    filename = path.join(@location, encodeURIComponent(key))
    if fs.existsSync(filename)
      _rm(filename)
    @_init()  # !TODO: Find a faster way to set @keys, length, and bytesInUse
    
  key: (n) ->
    return @keys[n]
    
  clear: () ->
    _emptyDirectory(@location)
    @keys = []
    @length = 0
    @bytesInUse = 0

  getBytesInUse: () ->
    return @bytesInUse
    
  _deleteLocation: () ->
    _rm(@location)
    @keys = []
    @length = 0
    @bytesInUse = 0

exports.LocalStorage = LocalStorage
exports.QUOTA_EXCEEDED_ERR = QUOTA_EXCEEDED_ERR
