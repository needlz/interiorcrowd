class DesignSpacePage

  @init: ->
    BudgetOptions.init()
    dimensionViewDetailsToggle = new OptionsContainerToggle(
      radioButtonsSelector: '[name="details_toggle"]',
      containerSelector: '.space-view-details'
    )
    dimensionViewDetailsToggle.init()
    SpacePicturesUploader.init()

    @bindContinueButton()

  @bindContinueButton: ->
    $('.continue').click (event) =>
      event.preventDefault()
      $('.text-error').text('')
      @clearHiddenInputs()
      $('#design_space').submit()

  @clearHiddenInputs: ->
    $('.space-pictures, .dimensions').find('input').attr('name', '') unless DimensionViewDetailsToggle.showing()

$ ->
  DesignSpacePage.init()
