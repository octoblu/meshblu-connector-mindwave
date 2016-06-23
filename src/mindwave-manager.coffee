_              = require 'lodash'
{EventEmitter} = require 'events'
net            = require 'net'

class MindwaveManager extends EventEmitter
  constructor: ({ @port=13854, @host='localhost' }={}) ->
    # hooks for testing
    @net = net

  close: (callback) =>
    return callback() unless @client?
    @client.removeAllListeners 'close'
    @client.end (error) =>
      @client = null
      callback error

  connect: ({@broadcastInterval, @blink, @data, @eeg}, callback) =>
    @_emit = _.throttle @emit, @broadcastInterval, {leading: true, trailing: false}
    return callback error if error?
    return callback() if @client?
    @client = net.connect @port, @host, @onConnect
    @_initialize callback

  _initialize: (callback) =>
    callback = _.once callback
    @client.on 'data', @_onData

    @client.once 'connect', =>
      callback()
      @client.once 'error', (error) =>
        console.error error.stack
        console.log 'Something bad happened, exiting...'
        process.exit 1

      @client.once 'close', =>
        console.log 'Lost connection, exiting...'
        process.exit 1

    @client.once 'error', callback
    @client.once 'timeout', callback

  isOnline: (callback) =>
    callback null, running: !!@client

  onConnect: =>
    config =
      enableRawOutput: true
      format: 'Json'
    @client.write JSON.stringify config

  _onData: (rawData) =>
    rawData = rawData.toString()
    rawDatas = rawData.split '\r\n'
    _.each rawDatas, (rawData) =>
      return if _.isEmpty rawData
      try
        data = JSON.parse rawData
      catch error
        console.error "Failed to parse:", rawData
        console.error error.stack ? error.message ? error
        return

      return @_emitEeg data if data.rawEeg?
      return @_emitBlink data if data.blinkStrength?
      @_emitData data

  _emitEeg: (data) =>
    return unless @eeg
    @_emit 'eeg', data

  _emitBlink: (data) =>
    return unless @blink
    @_emit 'blink', data

  _emitData: (data) =>
    return unless @data
    @_emit 'data', data

module.exports = MindwaveManager
