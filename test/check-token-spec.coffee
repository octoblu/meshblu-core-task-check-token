Datastore = require 'meshblu-core-datastore'
CheckToken = require '../src/check-token'

describe 'CheckToken', ->
  beforeEach (done) ->
    @datastore = new Datastore
      database: 'meshblu-core-task-check-token'
      collection: 'devices'

    @datastore.remove done

  beforeEach ->
    @sut = new CheckToken datastore: @datastore, pepper: 'totally-a-secret'

  describe '->do', ->
    context 'when given a valid token', ->
      beforeEach (done) ->
        record =
          uuid: 'thank-you-for-considering'
          token: 'never-gonna-guess-me'
          meshblu:
            tokens:
              'GpJaXFa3XlPf657YgIpc20STnKf2j+DcTA1iRP5JJcg=': {}
        @datastore.insert record, done

      beforeEach (done) ->
        request =
          metadata:
            responseId: 'used-as-biofuel'
            auth:
              uuid: 'thank-you-for-considering'
              token: 'the-environment'

        @sut.do request, (error, @response) => done error

      it 'should respond with a 204', ->
        expectedResponse =
          metadata:
            responseId: 'used-as-biofuel'
            code: 204
            status: 'No Content'

        expect(@response).to.deep.equal expectedResponse

    context 'when given a invalid token', ->
      beforeEach (done) ->
        record =
          uuid: 'thank-you-for-considering'
          meshblu:
            tokens: {}
        @datastore.insert record, done

      beforeEach (done) ->
        request =
          metadata:
            responseId: 'axed'
            auth:
              uuid: 'hatcheted'
              token: 'bodysprayed'

        @sut.do request, (error, @response) => done error

      it 'should respond with a 204', ->
        expectedResponse =
          metadata:
            responseId: 'axed'
            code: 403
            status: 'Forbidden'

        expect(@response).to.deep.equal expectedResponse
