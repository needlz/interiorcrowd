class @OptionsContainerToggle
  constructor: (@options)->

  init: ->
    @refreshView()
    @bindRadioButtons()
    @bindMobileButtons()

  showing: ->
    $(@options.radioButtonsSelector).filter(':checked').val() is 'yes'

  refreshView: (visible)->
    $(@options.containerSelector).toggle(visible)

  bindRadioButtons: ->
    $(@options.radioButtonsSelector).change (event)=>
      visible = @showing()
      $(@options.mobileButtonsSelector).find('[value="yes"]').prop('checked', visible == true)
      $(@options.mobileButtonsSelector).find('[value="no"]').prop('checked', visible == false)
      @refreshView(visible)

  bindMobileButtons: ->
    $(@options.mobileButtonsSelector).click (event)=>
      $button = $(event.target).closest(@options.mobileButtonsSelector)
      visible = $button.data('value') is 'yes'
      $(@options.radioButtonsSelector).filter('[value="yes"]').prop('checked', visible == true)
      $(@options.radioButtonsSelector).filter('[value="no"]').prop('checked', visible == false)
      @refreshView(visible)
