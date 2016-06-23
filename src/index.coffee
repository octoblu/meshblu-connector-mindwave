{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-mindwave:index')
MindwaveManager = require './mindwave-manager'

class Connector extends EventEmitter
  constructor: ->
    @mindwave = new MindwaveManager
    @mindwave.on 'blink', @_onBlink
    @mindwave.on 'data', @_onData
    @mindwave.on 'eeg', @_onEEG

  isOnline: (callback) =>
    @mindwave.isOnline (error, {running}) =>
      callback null, {running}

  close: (callback) =>
    debug 'on close'
    callback()

  _onBlink: (data) =>
    data.event = 'blink'
    @emit 'message', {devices: ['*'], data}

  _onData: (data) =>
    data.event = 'data'
    @emit 'message', {devices: ['*'], data}

  _onEEG: (data) =>
    data.event = 'eeg'
    @emit 'message', {devices: ['*'], data}

  onConfig: (device={}, callback=->) =>
    { @options, @events } = device
    debug 'on config', @options
    { broadcastInterval } = @options ? {}
    { blink, data, eeg } = @events ? {}
    @mindwave.connect { broadcastInterval, eeg, blink, data }, callback

  start: (device, callback) =>
    debug 'started'
    @onConfig device, callback

module.exports = Connector
