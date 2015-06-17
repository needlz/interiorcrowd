class DesignSpacePage

  @budgetSelector: '#design_space_f_budget'

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
    $feedbackTextarea = $(@feedbackTextareaSelector)
    if $feedbackTextarea.val() == @feedbackPlaceholder
      $feedbackTextarea.val ''
    @clearHiddenInputs()

    @validator.reset()
    budget = $.trim($(@budgetSelector).val())
    unless budget.length
      @validator.addMessage $("#err_budget"), I18n.budget.select_error, $('.design-budget')

    if @validator.valid
      $("#design_space [type=submit]").click()
    else
      @validator.focusOnMessage()
      false

  @bindContinueButton: ->
    $('.continueBtn').click(@onSubmitClick)

  @clearHiddenInputs: ->
    $('.space-pictures, .dimensions').find('input').attr('name', '') unless @dimensionViewDetailsToggle.showing()

$ ->
  DesignSpacePage.init()
