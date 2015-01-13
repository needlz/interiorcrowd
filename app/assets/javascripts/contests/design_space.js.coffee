class DimensionViewDetailsToggle

  @init: ->
    @.refreshView(@.showing())

    $('[name="details_toggle"]').change (event)->
      DimensionViewDetailsToggle.refreshView($(event.target).val())

  @showing: ->
    $('[name="details_toggle"]:checked').val() is 'yes'

  @refreshView: (value)->
    showDetailsBlock = (value )
    $('.space-view-details').toggle(showDetailsBlock)

class DesignSpacePage

  @init: ->
    BudgetOptions.init()
    DimensionViewDetailsToggle.init()
    SpacePicturesUploader.init()

    @bindContinueButton()

  @bindContinueButton: ->
    $('.continue').click (event) =>
      event.preventDefault()
      $('.text-error').html ''
      @clearHiddenInputs()
      $('#design_space').submit()

  @clearHiddenInputs: ->
    $('.space-pictures, .dimensions').find('input').attr('name', '') unless DimensionViewDetailsToggle.showing()

$ ->
  DesignSpacePage.init()
