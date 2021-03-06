class PTB.Routes.Map
  title: ''
  params: {}
  additionalParams: {}

  constructor: (path, routeData)->
    @path = path
    @title = routeData.title
    delete routeData.title
    @params = routeData

  matchParams: (queryParams)-> 
    paramsMatch = 0
    paramsLength = 0

    hasParams = false
    for paramName, paramVal of @params
      # paramName = paramName.replace('sortd', 'sort')
      paramsLength++
      hasParams = true
      for queryParamName, queryParamVal of queryParams
        # quertyParamName = queryParamName.replace('sortd', 'sort')
        if paramName == queryParamName and paramVal == queryParamVal
          paramsMatch++

    if paramsMatch == paramsLength
      paramsMatch
    else
      0

  generateRoute: (queryParams)->
    additionalParams = {}
    for queryParamName, queryParamValue of queryParams
      if @params[queryParamName] != queryParamValue
        additionalParams[queryParamName] = queryParamValue
    new PTB.Routes.Route @path, @params, additionalParams, @title