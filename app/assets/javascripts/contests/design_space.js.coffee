class DesignSpacePage

  @budgetDropdownSelector: '#design_space_f_budget'

  @init: ->
    BudgetOptions.init()
    @dimensionViewDetailsToggle = new OptionsContainerToggle(
      radioButtonsSelector: '[name="details_toggle"]',
      containerSelector: '.space-view-details'
    )
    @dimensionViewDetailsToggle.init()
    SpacePicturesUploader.init()
    @validator = new ValidationMessages()

    @bindContinueButton()

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
