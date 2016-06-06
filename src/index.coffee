{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-mindwave:index')
thinkgear       = require('node-thinkgear-sockets')
_               = require('lodash')

class Mindwave extends EventEmitter
  constructor: ->
    @client = thinkgear.createClient(enableRawOutput: true)
    @connected = false
    @DEFAULT_OPTIONS = broadcastInterval: 100
    debug 'Mindwave constructed'

  isOnline: (callback) =>
    callback null, running: true

  onMessage: (message) =>
    debug 'on message', message

  onConfig: (device) =>
    @options = device.options || @DEFAULT_OPTIONS

    @throttledEmit = _.throttle(((payload) =>
      debug 'throttled', payload
      @emit 'message',
        'devices': [ '*' ]
        'payload': payload
    ), @options.interval, 'leading': false)
    debug 'on config', @options

  start: (device) =>
    { @uuid } = device
    debug 'started', @uuid
    @onConfig device
    @setMindwave()

  getMindwaveConnection: () =>
    return unless !@connected
    @client.connect()
    @connected = true

  setMindwave: () =>
    debug 'connected to mindwave'

    @client.on 'data', (result) =>
      @throttledEmit result

    @client.on 'blink_data', (result) =>
      @throttledEmit result

    @getMindwaveConnection()
    @client.on 'end', ->
      @connected = false
      console.error 'mindwave client disconnected'


module.exports = Mindwave
