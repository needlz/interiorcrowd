class @DesignSpacePage

  @inchesInputs: '.in-inches'
  @budgetDropdownSelector: '#design_space_f_budget'

  @init: ->
    BudgetOptions.init()
    @dimensionViewDetailsToggle = new OptionsContainerToggle(
      radioButtonsSelector: '[name="details_toggle"]',
      containerSelector: '.space-view-details'
    )
    @dimensionViewDetailsToggle.init()
    SpacePicturesUploader.init(I18n.photos)
    @validator = new ValidationMessages()

    @bindContinueButton()

  @bindInchesInputs: ->
    $(@inchesInputs).NumberLimiter()

  @onSubmitClick: (event)=>
    event.preventDefault()
    $('.text-error').text('')
    @clearHiddenInputs

    @validator.reset()
    budget = parseInt($.trim($(@budgetDropdownSelector).val()))
    if isNaN(budget) || budget < 1
      @validator.addMessage $("#err_budget"), I18n.budget.select_error, $('.design-budget')

    if @validator.valid
      $("#design_space").submit()
    else
      @validator.focusOnMessage()
      false

  @bindContinueButton: ->
    $('.continue').click(@onSubmitClick)


  @clearHiddenInputs: ->
    $('.space-pictures, .dimensions').find('input').attr('name', '') unless @dimensionViewDetailsToggle.showing()

$ ->
  DesignSpacePage.init()
