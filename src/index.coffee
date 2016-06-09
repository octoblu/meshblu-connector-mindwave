_               = require 'lodash'
{EventEmitter}  = require 'events'
MindwaveClient        = require './mindwave-client'
debug           = require('debug')('meshblu-connector-mindwave:index')

class Mindwave extends EventEmitter
  constructor: ->
    @connected = false
    @connecting = false
    @DEFAULT_OPTIONS = broadcastInterval: 100

  isOnline: (callback) =>
    callback null, { running: @connected }

  onConfig: (device={}) =>
    { broadcastInterval } = device.options ? {}
    broadcastInterval ?= 100
    @throttledEmit = _.throttle @emitMessage, broadcastInterval, { leading: false }

  emitMessage: (eventName, payload={}) =>
    debug 'throttled', { eventName, payload }
    @emit 'message',
      'devices': [ '*' ],
      'topic': eventName,
      'payload': payload

  start: (device) =>
    @onConfig device
    @initMindwave()

  initMindwave: () =>
    return debug 'connected' if @connected
    return debug 'connecting' if @connecting

    @client = new MindwaveClient

    @client.on 'connect', =>
      debug 'connected'
      @connecting = false
      @connected = true

    @client.on 'error', (error) =>
      debug 'on error', error
      @throttledEmit 'error', { error }

    @client.on 'raw_data', (result) =>
      @throttledEmit 'raw_data', result

    @client.on 'data', (result) =>
      @throttledEmit 'data', result

    @client.on 'blink_data', (result) =>
      @throttledEmit 'blink_data', result

    @client.on 'end', =>
      @connecting = false
      @connected = false
      debug 'mindwave client disconnected'

    debug 'connecting to mindwave'
    @client.connect()
    @connecting = true

module.exports = Mindwave
