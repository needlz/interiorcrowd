class DimensionViewDetailsToggle

  @init: ->
    @refreshView()
    @bindRadioButtons()

  @showing: ->
    $('[name="details_toggle"]:checked').val() is 'yes'

  @refreshView: (value)->
    $('.space-view-details').toggle(@showing())

  @bindRadioButtons: ->
    $('[name="details_toggle"]').change (event)=>
      @refreshView()

class DesignSpacePage

  @init: ->
    BudgetOptions.init()
    DimensionViewDetailsToggle.init()
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
