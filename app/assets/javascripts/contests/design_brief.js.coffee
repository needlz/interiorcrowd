class ChooseRoomPage

  @validate: ->
    if $(".design_element:checked").length < 1
      @validator.addMessage $("#err_category"), I18n.errors.select_category, $('.packages')

    selectedRoomId = parseInt($('[name="design_brief[design_area]"]').val())
    if isNaN(selectedRoomId)
      @validator.addMessage $("#err_design_area"), I18n.errors.select_room, $('.rooms')

  @init: ->
    RoomsEditor.init()
    @validator = new ValidationMessages()
    @bindContinueButton()

  @onSubmitClick: (e)=>
    $('.text-error').html('')
    @validator.reset()
    @validate()

    if @validator.valid
      e.preventDefault()
      $("#design_categories").submit()
    else
      @validator.focusOnMessage()


  @bindContinueButton: ->
    $('.btn1-confirm').click(@onSubmitClick)

$(document).ready ->
  ChooseRoomPage.init()
