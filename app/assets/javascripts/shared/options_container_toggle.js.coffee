class @OptionsContainerToggle
  constructor: (@options)->

  init: ->
    @refreshView()
    @bindRadioButtons()

  showing: ->
    $(@options.radioButtonsSelector).filter(':checked').val() is 'yes'

  refreshView: ->
    $(@options.containerSelector).toggle(@showing())

  bindRadioButtons: ->
    $(@options.radioButtonsSelector).change (event)=>
      @refreshView()
