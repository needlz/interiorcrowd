class @EntriesVoicePlayback

  @init: (playerSelector)->
    $(playerSelector).each (i, element)=>
      @bindPlayback($(element).find('.playback-icon'))
      $player = $(element)
      AudioPlayer.init(
        playerContainer: $player,
        fileType: 'mp3',
        filePath: $player.find('.control .jp-jplayer').data('filepath')
        jPlayerOptions:
          ended: (event) ->
            @resetPlayer($player)
      )

  @bindPlayback: ($button)->
    $button.click =>
      $player = $button.closest('.player').find('.control')
      $description = $button.closest('.player').find('.voice .text')
      if $player.hasClass('hidden')
        @showPlayer($player, $description)
      else
        @hidePlayer($player, $description)

  @showPlayer: ($player, $description)->
    $player.removeClass('hidden')
    $description.hide()

  @hidePlayer: ($player, $description)->
    $player.addClass('hidden')
    $player.find('.jp-jplayer').jPlayer('stop')
    @resetPlayer($player)
    $description.show()

  @resetPlayer: ($player)->
    $player.find('.player-play').show()
    $player.find('.player-pause').hide()
