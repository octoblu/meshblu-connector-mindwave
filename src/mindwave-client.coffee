{EventEmitter} = require 'events'
net            = require 'net'

class MindwaveClient extends EventEmitter
  constructor: ({ @port=13854, @host='localhost' }={}) ->
    @config = {
      enableRawOutput: true,
      format: 'Json',
    }

  connect: =>
    @client = net.connect @port, @host, @onConnect
    @listen()

  onConnect: =>
    @client.write JSON.stringify @config

  parseData: (data) =>
    try
      json = JSON.parse(data.toString())
    catch error
      console.error error
      @emit 'parse_error', data.toString()
      return

    return @emit 'raw_data', json if json.rawEeg?
    return @emit 'blink_data', json if json.blinkStrength?
    @emit 'data', json

  listen: =>
    @client.on 'data', @parseData

    @client.on 'connect', (data) =>
      @emit 'connect', data

    @client.on 'close', (data) =>
      @emit 'close', data

    @client.on 'error', (data) =>
      @emit 'error', data

    @client.on 'end', (data) =>
      @emit 'end', data

    @client.on 'timeout', (data) =>
      @emit 'timeout', data

module.exports = MindwaveClient
