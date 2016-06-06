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

  onMessage: (message) =>
    debug 'on message', message

  onConfig: (device) =>
    @options = device.options || @DEFAULT_OPTIONS
    @setMindwave()
    debug 'on config', @options

  start: (device) =>
    { @uuid } = device
    debug 'started', @uuid
    @onConfig device

  getMindwaveConnection: () =>
    if !@connected
      @client.connect()
      @connected = true

  setMindwave: () =>
    if !@connected
      debug 'connected to mindwave'
      throttledEmit = _.throttle(((payload) ->
        @emit 'message', payload
      ), @options.broadcastInterval || 100)

      @client.on 'data', (result) ->
        data =
          devices: '*'
          payload: result
        throttledEmit data

      @client.on 'blink_data', (result) ->
        data =
          devices: '*'
          payload: result
        throttledEmit data

      @getMindwaveConnection()
      @client.on 'end', ->
        @connected = false
        console.error 'mindwave client disconnected'


module.exports = Mindwave
