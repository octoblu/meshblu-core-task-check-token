TokenManager = require 'meshblu-core-manager-token'
http = require 'http'

class CheckToken
  constructor: ({datastore, pepper, uuidAliasResolver}) ->
    @tokenManager = new TokenManager {datastore, pepper, uuidAliasResolver}

  _doCallback: (request, code, callback) =>
    response =
      metadata:
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]
    callback null, response

  do: (request, callback) =>
    {uuid,token} = request.metadata?.auth ? {}
    return @_doCallback request, 401, callback unless uuid? and token?

    @tokenManager.verifyToken {uuid, token}, (error, verified) =>
      return callback error if error?
      return @_doCallback request, (if verified then 204 else 401), callback

module.exports = CheckToken
