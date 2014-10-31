
# keys are the list of logging to enable... 
logLevels = 
  debug: 2
  warn: 4
  error: 8

logLevel = logLevels.debug

logKeys = {}

verbosityLevels = 
  whisper: 2 # third level verbosity
  talk: 4 # second level verbosity
  speech: 8 # the first level verbosity
  scream: 16 # can't be turned off... 

enable = (key) ->
  logKeys[key] = new RegExp key
  
disable = (key) ->
  delete logKeys[key]

setLevel = (lvl) ->
  if logLevels.hasOwnProperty(lvl)
    logLevel = logLevels[lvl]

setKeys = (keys = []) ->
  keys = 
    if keys instanceof Array
      keys
    else
      [ keys ]
  for key in keys
    enable(key)

transports = [ ]

contains = (ary, item) ->
  for x in ary
    if item == x 
      return true
  false

isTransportValid = (logger) ->
  (logger.log instanceof Function) and (logger.warn instanceof Function) and (logger.error instanceof Function)

addTransport = (logger) ->
  if isTransportValid logger
    if not contains transports, logger
      transports.push logger
  else
    throw {error: 'invalid_transport', description: 'must have .log, .warn, and .error function.'}

addTransport console

removeTransport = (logger) ->
  for x, i in transports
    if logger == x
      transports.splice i, 1

_log = (args...) ->
  for trans in transports
    trans.log args...

_warn = (args...) ->
  for trans in transports 
    trans.warn args...
    
_error = (args...) ->
  for trans in transports 
    trans.error args...

# we take the first as a key... 
debug = (key, args...) ->
  if logLevel <= logLevels.debug 
    for k, regex of logKeys
      if key.match regex
        _log 'DEBUG ----------', key
        _log JSON.stringify(args, null, 2)

whisper = (args...) ->

talk = (args...) ->

speech = (args...) ->

scream = (args...) ->
  _log args...

warn = (args...) ->
  if logLevel <= logLevels.warn
    _warn "*** WARN START ***"
    _warn args...
    _warn "*** WARN END   ***"

error = (args...) ->
  if logLevel <= logLevels.error
    _error '****** ERROR START ******'
    _error args...
    for arg in args
      if arg?.stack
        _error arg.stack
    _error '****** ERROR END   ******'

croak = (args...) ->
  error args...
  process.exit()

module.exports = 
  addTransport: addTransport
  removeTransport: removeTransport
  
  setLevel: setLevel
  enable: enable
  disable: disable
  setKeys: setKeys
  debug: debug
  warn: warn
  error: error
  log: _log
  whisper: whisper
  talk: talk
  speech: speech
  scream: scream
  croak: croak
