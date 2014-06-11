class PTB.Routes.Route
  constructor: (@path, @pathParams, @searchParams, @title)->
    @params = {}
    # Who needs merge?
    for k, v of @pathParams
      @params[k] = v
    for k, v of @searchParams
      @params[k] = v

  hash: ->
    arrayStringParams = for paramName, paramVal of @searchParams
      encodedVal = encodeURIComponent(paramVal).replace(/%20/g, "+").replace(/%2F/g, '/')
      paramName + (if paramVal then "=#{encodedVal}" else '')
    arrayStringParams.join('&')

  trailingSlashPath: ->
    @path.replace(/\/$/, '') + '/'