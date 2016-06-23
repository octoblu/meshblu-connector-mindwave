{EventEmitter} = require 'events'
MindwaveManager = require '../src/mindwave-manager'

describe 'MindwaveManager', ->
  beforeEach 'setup', ->
    @sut = new MindwaveManager
    {@net} = @sut
    @client = new EventEmitter
    @client.end = sinon.stub().yields null
    @net.connect = => @client

  beforeEach 'connect', (done) ->
    options =
      eeg: true
      blink: true
      data: true
      broadcastInterval: 500
    @sut.connect options, (error) =>
      @sut._emit = sinon.stub()
      done error
    @client.emit 'connect'

  afterEach (done) ->
    @sut.close done

  describe '-> isOnline', ->
    beforeEach (done) ->
      @sut.isOnline (error, {@running}) =>
        done error

    it 'should yield running', ->
      expect(@running).to.be.true

  describe '->_onData', ->
    context 'when rawEeg', ->
      beforeEach (done) ->
        data =
          rawEeg: 'something'
          foo: 'bar'
        @client.once 'data', => done()
        @client.emit 'data', JSON.stringify data

      it 'should emit eeg', ->
        data =
          rawEeg: 'something'
          foo: 'bar'
        expect(@sut._emit).to.have.been.calledWith 'eeg', data

    context 'when blinkStrength', ->
      beforeEach (done) ->
        data =
          blinkStrength: 'something'
          foo: 'bar'
        @client.once 'data', => done()
        @client.emit 'data', JSON.stringify data

      it 'should emit blink', ->
        data =
          blinkStrength: 'something'
          foo: 'bar'
        expect(@sut._emit).to.have.been.calledWith 'blink', data

    context 'when boring plain data', ->
      beforeEach (done) ->
        data =
          foo: 'bar'
        @client.once 'data', => done()
        @client.emit 'data', JSON.stringify data

      it 'should emit blink', ->
        data =
          foo: 'bar'
        expect(@sut._emit).to.have.been.calledWith 'data', data
