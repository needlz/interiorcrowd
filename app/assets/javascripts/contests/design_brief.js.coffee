class ChooseRoomPage

  @validate: ->
    if $(".design_element:checked").length < 1
      @validator.addMessage $("#err_category"), I18n.errors.select_category, $('.packages')

    anyRoomSelected = $('[name="design_brief[design_area][]"]:checked').length
    unless anyRoomSelected
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
      $("#design_categories [type=submit]").click()
    else
      @validator.focusOnMessage()


  @bindContinueButton: ->
    $('.btn1-confirm').click(@onSubmitClick)

$(document).ready ->
  ChooseRoomPage.init()
  mixpanel.track_forms '#design_categories', 'Contest creation - Step 1', (form)->
    $form = $(form)
    { data: $form.serializeArray() }
