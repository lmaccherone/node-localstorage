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

class LocalStorage
  constructor: (@location) ->
    @length = 0
    @keys = []
    @_init()
  
  _init: () ->
    if fs.existsSync(@location)
      unless fs.statSync(@location).isDirectory()
        throw new Error("A file exists at the location '#{@location}' when trying to create/open localStorage")
    unless fs.existsSync(@location)
      fs.mkdirSync(@location)
    @keys = fs.readdirSync(@location)
    @length = @keys.length
  
  setItem: (key, value) ->
    key = key.toString()
    filename = path.join(@location, key)
    existsBeforeSet = fs.existsSync(filename)
    fs.writeFileSync(filename, value.toString(), 'utf8')
    unless existsBeforeSet
      @keys.push(key)
      @length = @keys.length

  getItem: (key) ->
    key = key.toString()
    filename = path.join(@location, key)
    if fs.existsSync(filename)
      return fs.readFileSync(filename, 'utf8')
    else
      return null
  
  removeItem: (key) ->
    key = key.toString()
    filename = path.join(@location, key)
    if fs.existsSync(filename)
      _rm(filename)
    @_init()  # !TODO: Find a faster way to set @keys and length
    
  key: (n) ->
    return @keys[n]
    
  clear: () ->
    _emptyDirectory(@location)
    @keys = []
    @length = 0
    
  _deleteLocation: () ->
    _rm(@location)
    @keys = []
    @length = 0
    
exports.LocalStorage = LocalStorage
