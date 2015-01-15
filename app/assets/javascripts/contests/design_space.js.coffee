class DesignSpacePage

  @budgetDropdownSelector: '#design_space_f_budget'

  @init: ->
    BudgetOptions.init()
    dimensionViewDetailsToggle = new OptionsContainerToggle(
      radioButtonsSelector: '[name="details_toggle"]',
      containerSelector: '.space-view-details'
    )
    dimensionViewDetailsToggle.init()
    SpacePicturesUploader.init()

    @bindContinueButton(dimensionViewDetailsToggle)

  @bindContinueButton: (dimensionViewDetailsToggle)->
    $('.continue').click (event) =>
      event.preventDefault()
      $('.text-error').text('')
      @clearHiddenInputs(dimensionViewDetailsToggle)

      budget = $.trim($(@budgetDropdownSelector).val())
      messageToFocus = null

      if budget < 1
        messageToFocus = $("#err_budget")
        messageToFocus.text(I18n.budget.select_error)

      if messageToFocus
        $(messageToFocus).get(0).scrollIntoView()
        false
      else
        $("#design_space").submit()

  @clearHiddenInputs: (dimensionViewDetailsToggle)->
    $('.space-pictures, .dimensions').find('input').attr('name', '') unless dimensionViewDetailsToggle.showing()

$ ->
  DesignSpacePage.init()
