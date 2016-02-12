class DesignSpacePage

  @budgetSelector: '#design_space_f_budget'
  @zipSelector: '#design_space_zip'

  @init: ->
    DesignSpaceOptions.init(feedbackPlaceholder: I18n.other_feedback.placeholder)
    @dimensionViewDetailsToggle = new OptionsContainerToggle(
      radioButtonsSelector: '[name="details_toggle"]',
      mobileButtonsSelector: '.customRadioBtn',
      containerSelector: '.space-view-details'
    )
    @dimensionViewDetailsToggle.init()
    SpacePicturesUploader.init(I18n.photos)
    @validator = new ValidationMessages()
    @bindContinueButton()

    mixpanel.track_forms '#design_space', 'Contest creation - Step 3', (form)->
      $form = $(form)
      { data: $form.serializeArray() }

  @onSubmitClick: (event)=>

    event.preventDefault()
    $('.text-error').text('')
    DesignSpaceOptions.clearFeedback()
    @clearHiddenInputs()

    @validator.reset()

    zip = $.trim($(@zipSelector).val())
    zip_regex = /^\d{5}(-\d{4})?$/
    unless zip.match zip_regex
      @validator.addMessage $("#err_zip"), I18n.location.wrong_value_error, $('.location-zip')
    unless zip.length
      @validator.addMessage $("#err_zip"), I18n.location.empty_value_error, $('.location-zip')

    budget = $.trim($(@budgetSelector).val())
    unless budget.length
      @validator.addMessage $("#err_budget"), I18n.budget.select_error, $('.design-budget')

    if @validator.valid
      $("form#design_space").submit()
    else
      @validator.focusOnMessage()
      false

  @bindContinueButton: ->
    $('.continueBtn').click(@onSubmitClick)
    $("#design_space [type=submit]").click(@onSubmitClick)

  @clearHiddenInputs: ->
    $('.space-pictures, .dimensions').find('input').attr('name', '') unless @dimensionViewDetailsToggle.showing()

$ ->
  DesignSpacePage.init()
