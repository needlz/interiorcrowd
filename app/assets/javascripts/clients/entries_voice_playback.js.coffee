class @EntriesVoicePlayback

  @descriptionSelector: '.voice-description';
  @playbackSwitcherSelector: '.playback-switch';

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
      $playerContainer = $button.closest('.player')
      $description = $playerContainer.find(@descriptionSelector)
      if $playerContainer.find('.control').hasClass('hidden')
        @showPlayer($playerContainer, $description)
      else
        @hidePlayer($playerContainer, $description)

  @showPlayer: ($playerContainer, $description)->
    $playerContainer.find('.control').removeClass('hidden')
    $playerContainer.find(@playbackSwitcherSelector).addClass('active')
    $description.hide()

  @hidePlayer: ($playerContainer, $description)->
    $playerContainer.find('.control').addClass('hidden')
    $playerContainer.find('.jp-jplayer').jPlayer('stop')
    $playerContainer.find(@playbackSwitcherSelector).removeClass('active')
    @resetPlayer($playerContainer)
    $description.show()

  @resetPlayer: ($playerContainer)->
    $playerContainer.find('.player-play').show()
    $playerContainer.find('.player-pause').hide()
