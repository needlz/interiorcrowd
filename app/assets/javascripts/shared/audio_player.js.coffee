class @AudioPlayer

  @init: (options)->
    player = options.playerContainer
    playerData = player.find('.jp-jplayer')

    fileOptions = {}
    fileOptions[options.fileType] = playerData.data('filepath')
    playerOptions = $.extend({
        ready: (event) ->
          playerData.jPlayer('setMedia', fileOptions)
        solution: 'html'
        supplied: 'mp3, m4a, oga'
        wmode: 'window'
        useStateClassSkin: true
        autoBlur: false
        smoothPlayBar: false
        keyEnabled: true
        remainingDuration: true
        toggleDuration: true
        cssSelectorAncestor: '#' + player.find('.jp-audio').attr('id')
      },
      options.jPlayerOptions
    )
    playerData.jPlayer(playerOptions)

    player.find('.volume-bar').slider
      value: 50
      slide: (event, ui) ->
        playerData.jPlayer 'volume', ui.value / 100

    player.find('.player-pause').hide()

    player.find('.player-play').click ->
      playerData.jPlayer 'play'
      player.find('.player-play').hide()
      player.find('.player-pause').show()

    player.find('.player-pause').click ->
      playerData.jPlayer 'pause'
      player.find('.player-play').show()
      player.find('.player-pause').hide()
