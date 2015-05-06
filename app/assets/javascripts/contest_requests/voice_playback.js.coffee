$(document).ready ->
  $('#jquery_jplayer_1').jPlayer
    ready: (event) ->
      $(this).jPlayer 'setMedia', mp3: '#{ request.sound.url_for_streaming }'
      return
    solution: 'html'
    supplied: 'mp3, m4a, oga'
    wmode: 'window'
    useStateClassSkin: true
    autoBlur: false
    smoothPlayBar: true
    keyEnabled: true
    remainingDuration: true
    toggleDuration: true
    ended: (event) ->
      $('.player-play').show()
      $('.player-pause').hide()
      return

  $('.volume-bar').slider
    value: 50
    slide: (event, ui) ->
      $('#jquery_jplayer_1').jPlayer 'volume', ui.value / 100
      return

  $('.player-pause').hide()

  $('.player-play').click ->
    $('#jquery_jplayer_1').jPlayer 'play'
    $('.player-play').hide()
    $('.player-pause').show()

  $('.player-pause').click ->
    $('#jquery_jplayer_1').jPlayer 'pause'
    $('.player-play').show()
    $('.player-pause').hide()
