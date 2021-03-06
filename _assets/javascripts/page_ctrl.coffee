class PTB.PageCtrl
  gamesUrl: '/games.json'
  games: []
  filteredGames: []

  constructor: ->
    @e = $$('.table')
    @ePageTitle = $$('title')
    @ePageSubtitle = $$('.subtitle')

    @dataService = PTB.Services.inject 'DataService' # Make-believe dependency injection
    @i18n = PTB.Services.inject('I18n')
    @router = PTB.Services.inject('RouterService')

    @build()

    @dataService.all (data)=>
      @parseResults(data)

  build: ->
    @tooltipler = new PTB.Tooltipler

  parseResults: (data)->
    console.time 'Build time'

    for gameAttr in data.games
      gameAttr.flagsList = data.flags
      gameAttr.osFlagsList = data.osFlags
      gameAttr.featuresFlagsList = data.featuresFlags
      gameAttr.flagsLabels = @i18n.t 'flags'
      @games.push(new PTB.Game(gameAttr))
    @filteredGames = @games
    @buildContainers()

  buildContainers: ->
    @gamesContainer = new PTB.GamesContainer @games
    @filtersContainer = new PTB.FiltersContainer
    @sortersContainer = new PTB.SortersContainer
    @filter()
    if @router.hasAdditionalParams() or not @gamesContainer.isPreRendered()
      @render()
    else
      @setGames()
    @bind()

  bind: ->
    @filtersContainer.on 'change', (shrinker)=> 
      @filter(shrinker)
      @render()
    @sortersContainer.on 'change', => 
      @sort()
      @render()
    @router.onRouteChange (route)=> @setPageTitle route.title
    @e.addEventListener 'click', @onClick.bind(@)

  setGames: ->
    @gamesContainer.setGames @filteredGames

  render: ->
    @setGames()
    console.time 'Render time'
    @gamesContainer.render()
    console.timeEnd 'Render time'

  # The shrinker parameter is to optimize
  # So if we know the change in the filtering
  # will shrink our current list, then we start processing
  # from the previous filtered list rather than the whole
  # list of games.
  filter: (shrinker)->
    console.time 'Filter time'
    accepted = if shrinker then @filteredGames else @games
    rejected = []
    accepted = @filtersContainer.filter(@games, rejected)
    #console.log 'Accepted: ', accepted.length
    #console.log 'Rejected: ', rejected.length
    console.timeEnd 'Filter time'
    #console.time 'Toggle time'
    # if not shrinker
      # game.toggle true for game in accepted
    # game.toggle false for game in rejected
    #console.timeEnd 'Toggle time'
    @filteredGames = accepted

    @sort()

  sort: ->
    @sortersContainer.sort @filteredGames

  onClick: (ev)->
    if ev.target.classList.contains('tag')
      @filtersContainer.broadcast('tag', ev.target.innerHTML)

  setPageTitle: (title)->
    previousTitle = @ePageTitle.innerHTML
    previousTitle = previousTitle.split(/\s+\-\s+/)[0]
    @ePageTitle.innerHTML = "#{previousTitle} - #{title}"
    @ePageSubtitle.innerHTML = title
