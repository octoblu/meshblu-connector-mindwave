Mindwave = require '../'

describe 'Mindwave', ->
  beforeEach ->
    @sut = new Mindwave

  describe '->start', ->
    it 'should be a method', ->
      expect(@sut.start).to.be.a 'function'

    describe 'when called with a device', ->
      it 'should not throw an error', ->
        expect(=> @sut.start({ uuid: 'hello' })).to.not.throw(Error)

  describe '->isOnline', ->
    it 'should be a method', ->
      expect(@sut.isOnline).to.be.a 'function'

    describe 'when called and connected', ->
      beforeEach ->
        @sut.connected = true

      it 'should return running true', (done) ->
        @sut.isOnline (error, response) =>
          expect(error).to.not.exist
          expect(response.running).to.be.true
          done()

    describe 'when called and not connected', ->
      beforeEach ->
        @sut.connected = false

      it 'should return running true', (done) ->
        @sut.isOnline (error, response) =>
          expect(error).to.not.exist
          expect(response.running).to.be.false
          done()

  describe '->onConfig', ->
    it 'should be a method', ->
      expect(@sut.onConfig).to.be.a 'function'

    describe 'when called with a config', ->
      it 'should not throw an error', ->
        expect(=> @sut.onConfig { type: 'hello' }).to.not.throw(Error)
