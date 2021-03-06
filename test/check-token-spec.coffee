Datastore  = require 'meshblu-core-datastore'
CheckToken = require '../src/check-token'
mongojs    = require 'mongojs'

describe 'CheckToken', ->
  beforeEach (done) ->
    @uuidAliasResolver = resolve: (uuid, callback) => callback null, uuid
    database = mongojs 'meshblu-core-task-check-token', ['tokens']
    @datastore = new Datastore
      database: database
      collection: 'tokens'

    database.tokens.remove done

  beforeEach ->
    @sut = new CheckToken
      datastore: @datastore
      pepper: 'totally-a-secret'
      uuidAliasResolver: @uuidAliasResolver

  describe '->do', ->
    context 'when given a valid token', ->
      beforeEach (done) ->
        record =
          uuid: 'thank-you-for-considering'
          hashedToken: 'ZOGZOX7K4XywpyNFjVS+6SfbXFux8FNW7VT6NWmsz6E='
          metadata: {
            createdAt: new Date()
          }
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
          hashedToken: 'this-will-not-work'
        @datastore.insert record, done

      beforeEach (done) ->
        request =
          metadata:
            responseId: 'axed'
            auth:
              uuid: 'hatcheted'
              token: 'bodysprayed'

        @sut.do request, (error, @response) => done error

      it 'should respond with a 401', ->
        expectedResponse =
          metadata:
            responseId: 'axed'
            code: 401
            status: 'Unauthorized'

        expect(@response).to.deep.equal expectedResponse
