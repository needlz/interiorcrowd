$(document).ready ->
  AudioPlayer.init({
    playerContainer: $('.player'),
    fileType: 'mp3',
    jPlayerOptions:
      ended: (event) ->
        $('.player-play').show()
        $('.player-pause').hide()
  })
