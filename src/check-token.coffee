TokenManager = require 'meshblu-core-manager-token'
http = require 'http'

class CheckToken
  constructor: (options={}) ->
    {@datastore,pepper} = options
    @tokenManager = new TokenManager
      datastore: @datastore
      pepper: pepper

  do: (request, callback) =>
    {uuid,token} = request.metadata.auth
    @tokenManager.verifyToken uuid: uuid, token: token, (error, verified) =>
      return callback error if error?

      code = 403
      code = 204 if verified

      response =
        metadata:
          responseId: request.metadata.responseId
          code: code
          status: http.STATUS_CODES[code]

      callback null, response

module.exports = CheckToken
