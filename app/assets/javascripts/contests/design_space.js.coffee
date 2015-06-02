class @DesignSpacePage
  @maxValueForInches = 11.99
  @inchesInputs: '.in-inches'
  @budgetDropdownSelector: '#design_space_f_budget'
  @feedbackTextareaSelector: 'textarea[name="design_space[feedback]"]'

  @init: (options)->
    BudgetOptions.init()
    @dimensionViewDetailsToggle = new OptionsContainerToggle(
      radioButtonsSelector: '[name="details_toggle"]',
      containerSelector: '.space-view-details'
    )
    @dimensionViewDetailsToggle.init()
    @feedbackPlaceholder = options.feedbackPlaceholder
    SpacePicturesUploader.init(I18n.photos)
    @validator = new ValidationMessages()

    @bindContinueButton()

    @setupFeedbackPlaceholder()

    mixpanel.track_forms '#design_space', 'Contest creation - Step 3', (form)->
      $form = $(form)
      { data: $form.serializeArray() }

  @bindInchesInputs: ->
    $(@inchesInputs).NumberLimiter(@maxValueForInches)

  @onSubmitClick: (event)=>
    event.preventDefault()
    $('.text-error').text('')
    $feedbackTextarea = $(@feedbackTextareaSelector)
    if $feedbackTextarea.val() == @feedbackPlaceholder
      $feedbackTextarea.val ''
    @clearHiddenInputs

    @validator.reset()
    budget = $.trim($(@budgetDropdownSelector).val())
    unless budget.length
      @validator.addMessage $("#err_budget"), I18n.budget.select_error, $('.design-budget')

    if @validator.valid
      $("#design_space [type=submit]").click()
    else
      @validator.focusOnMessage()
      false

  @bindContinueButton: ->
    $('.continue').click(@onSubmitClick)


  @clearHiddenInputs: ->
    $('.space-pictures, .dimensions').find('input').attr('name', '') unless @dimensionViewDetailsToggle.showing()

  @setupFeedbackPlaceholder: ->
    $textarea = $(@feedbackTextareaSelector)

    placeholder = @feedbackPlaceholder
    $textarea.val(placeholder)
    $textarea.focus ->
      if $(this).val() == placeholder
        $(this).val ''
    $textarea.blur ->
      if $(this).val() == ''
        $(this).val placeholder

$ ->
  DesignSpacePage.init(feedbackPlaceholder: I18n.other_feedback.placeholder)
