Connector = require '../'

describe 'Connector', ->
  beforeEach (done) ->
    @sut = new Connector
    @sut.emit = sinon.stub()
    {@mindwave} = @sut
    @mindwave.connect = sinon.stub().yields null
    @sut.start {}, done

  afterEach (done) ->
    @sut.close done

  describe '->isOnline', ->
    beforeEach (done) ->
      @mindwave.isOnline = sinon.stub().yields null, running: true
      @sut.isOnline (error, {@running}) =>
        done error

    it 'should yield running true', ->
      expect(@running).to.be.true

  describe '->onConfig', ->
    beforeEach (done) ->
      options =
        broadcastInterval: 500
      events =
        blink: true
        data: false
        eeg: false

      @sut.onConfig {options, events}, done

    it 'should call mindwave.connect', ->
      expect(@mindwave.connect).to.have.been.calledWith eeg: false, data: false, blink: true, broadcastInterval: 500

  describe '->on blink', ->
    beforeEach (done) ->
      data =
        blinkStrength: 2
        foo: 'bar'
      @mindwave.once 'blink', => done()
      @mindwave.emit 'blink', data

    it 'should emit message', ->
      data =
        event: 'blink'
        blinkStrength: 2
        foo: 'bar'
      expect(@sut.emit).to.have.been.calledWith 'message', {devices: ["*"], data}

  describe '->on data', ->
    beforeEach (done) ->
      data =
        foo: 'bar'
      @mindwave.once 'data', => done()
      @mindwave.emit 'data', data

    it 'should emit message', ->
      data =
        event: 'data'
        foo: 'bar'
      expect(@sut.emit).to.have.been.calledWith 'message', {devices: ["*"], data}

  describe '->on eeg', ->
    beforeEach (done) ->
      data =
        foo: 'bar'
      @mindwave.once 'eeg', => done()
      @mindwave.emit 'eeg', data

    it 'should emit message', ->
      data =
        event: 'eeg'
        foo: 'bar'
      expect(@sut.emit).to.have.been.calledWith 'message', {devices: ["*"], data}
