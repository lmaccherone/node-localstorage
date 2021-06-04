path = require('path')
fs = require('fs')
events = require('events')
writeSync = require('write-file-atomic').sync

KEY_FOR_EMPTY_STRING = '---.EMPTY_STRING.---'  # Chose something that no one is likely to ever use

_emptyDirectory = (target) ->
  _rm(path.join(target, p)) for p in fs.readdirSync(target)

_rm = (target) ->
  if fs.statSync(target).isDirectory()
    _emptyDirectory(target)
    fs.rmdirSync(target)
  else
    fs.unlinkSync(target)

_escapeKey = (key) ->
  if key is ''
    newKey = KEY_FOR_EMPTY_STRING
  else
    newKey = "#{key}"
  return newKey

class QUOTA_EXCEEDED_ERR extends Error
  constructor: (@message = 'Unknown error.') ->
    super()
    if Error.captureStackTrace?
      Error.captureStackTrace(this, @constructor)
    @name = @constructor.name

  toString: () ->
    return "#{@name}: #{@message}"

class StorageEvent
  constructor: (@key, @oldValue, @newValue, @url, @storageArea = 'localStorage') ->

class MetaKey # MetaKey contains key and size
  constructor: (@key, @index) ->
    unless this instanceof MetaKey
      return new MetaKey(@key, @index)

createMap = -> # createMap contains Metakeys as properties
  Map = ->
    return
  Map.prototype = Object.create(null);
  return new Map()


class LocalStorage extends events.EventEmitter
  instanceMap = {}

  constructor: (@_location, @quota = 5 * 1024 * 1024) ->
    super()
    # super(_location, quota)
    # @_location = _location
    # @quota = quota
    unless this instanceof LocalStorage
      return new LocalStorage(@_location, @quota)

    @_location = path.resolve(@_location)

    if instanceMap[@_location]?
      return instanceMap[@_location]

    @length = 0  # !TODO: Maybe change this to a property with __defineProperty__
    @_bytesInUse = 0
    @_keys = []
    @_metaKeyMap = createMap()
    @_eventUrl = "pid:" + process.pid
    @_init()
    @_QUOTA_EXCEEDED_ERR = QUOTA_EXCEEDED_ERR

    if Proxy?
      handler =
        set: (receiver, key, value) =>
          if @[key]?
            return @[key] = value
          else
            @setItem(key, value)

        get: (receiver, key) =>
          if @[key]?
            return @[key]
          else
            return @getItem(key)

      instanceMap[@_location] = new Proxy(this, handler)
      return instanceMap[@_location]

    # else it'll return this
    instanceMap[@_location] = this
    return instanceMap[@_location]
    
  _init: () ->
    try
      stat = fs.statSync(@_location)
      if stat? and not stat.isDirectory()
        throw new Error("A file exists at the location '#{@_location}' when trying to create/open localStorage")
      # At this point, it exists and is definitely a directory. So read it.
      @_bytesInUse = 0
      @length = 0

      _keys = fs.readdirSync(@_location)
      for k, index in _keys
        _decodedKey = decodeURIComponent(k)
        @_keys.push(_decodedKey)
        _MetaKey = new MetaKey(k, index)
        @_metaKeyMap[_decodedKey] = _MetaKey
        stat = @_getStat(k)
        if stat?.size?
          _MetaKey.size = stat.size
          @_bytesInUse += stat.size

      @length = _keys.length
      return
    catch e
      # If it errors, that might mean it didn't exist, so try to create it
      if e.code != "ENOENT"
        throw e
      try
        fs.mkdirSync(@_location, { recursive: true })
      catch e
        if e.code != "EEXIST"
          throw e
      return

  setItem: (key, value) ->
    hasListeners = events.EventEmitter.listenerCount(this, 'storage')
    oldValue = null
    if hasListeners
      oldValue = this.getItem(key)
    key = _escapeKey(key)
    encodedKey = encodeURIComponent(key)
    # encodedKey = encodeURIComponent(key).replace(/[!'()]/g, escape).replace(/\*/g, "%2A")

    filename = path.join(@_location, encodedKey)
    valueString = "#{value}"
    valueStringLength = valueString.length
    metaKey = @_metaKeyMap[key]
    existsBeforeSet = !!metaKey
    if existsBeforeSet
      oldLength = metaKey.size
    else
      oldLength = 0
    if @_bytesInUse - oldLength + valueStringLength > @quota
      throw new QUOTA_EXCEEDED_ERR()
    writeSync(filename, valueString, {encoding:'utf8'})
    unless existsBeforeSet
      metaKey = new MetaKey(encodedKey, (@_keys.push(key)) - 1)
      metaKey.size = valueStringLength
      @_metaKeyMap[key] = metaKey
      @length += 1
      @_bytesInUse += valueStringLength
    if hasListeners
      evnt = new StorageEvent(key, oldValue, value, @_eventUrl)
      this.emit('storage', evnt)

  getItem: (key) ->
    key = _escapeKey(key)
    metaKey = @_metaKeyMap[key]
    if !!metaKey
      filename = path.join(@_location, metaKey.key)
      return fs.readFileSync(filename, 'utf8')
    else
      return null

  _getStat: (key) ->
    key = _escapeKey(key)
    filename = path.join(@_location, encodeURIComponent(key))
    try
      return fs.statSync(filename)
    catch
      return null

  removeItem: (key) ->
    key = _escapeKey(key)
    metaKey = @_metaKeyMap[key]
    if (!!metaKey)
      hasListeners = events.EventEmitter.listenerCount(this, 'storage')
      oldValue = null
      if hasListeners
        oldValue = this.getItem(key)
      delete @_metaKeyMap[key]
      @length -= 1
      @_bytesInUse -= metaKey.size
      filename = path.join(@_location, metaKey.key)
      @_keys.splice(metaKey.index,1)
      for k,v of @_metaKeyMap
        meta = @_metaKeyMap[k]
        if meta.index > metaKey.index
          meta.index -= 1
      _rm(filename)
      if hasListeners
        evnt = new StorageEvent(key, oldValue, null, @_eventUrl)
        this.emit('storage', evnt)

  key: (n) ->
    rawKey = @_keys[n]
    if rawKey is KEY_FOR_EMPTY_STRING
      return ''
    else
      return rawKey 

  clear: () ->
    _emptyDirectory(@_location)
    @_metaKeyMap = createMap()
    @_keys = []
    @length = 0
    @_bytesInUse = 0
    if events.EventEmitter.listenerCount(this, 'storage')
      evnt = new StorageEvent(null, null, null, @_eventUrl)
      this.emit('storage', evnt)

  _getBytesInUse: () ->
    return @_bytesInUse

  _deleteLocation: () ->
    delete instanceMap[@_location]
    _rm(@_location)
    @_metaKeyMap = {}
    @_keys = []
    @length = 0
    @_bytesInUse = 0

class JSONStorage extends LocalStorage

  setItem: (key, value) ->
    newValue = JSON.stringify(value)
    super(key, newValue)

  getItem: (key) ->
    return JSON.parse(super(key))

exports.LocalStorage = LocalStorage
exports.JSONStorage = JSONStorage
exports.QUOTA_EXCEEDED_ERR = QUOTA_EXCEEDED_ERR
