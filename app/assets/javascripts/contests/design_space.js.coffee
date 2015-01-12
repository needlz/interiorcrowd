$ ->
  BudgetOptions.init()
  DimensionViewDetailsToggle.init()

  $('[name="details_toggle"]').change (event)->
    DimensionViewDetailsToggle.refreshView($(event.target).val())

  $(".continue").click (e) ->
    e.preventDefault()
    $(".text-error").html ""
    bool = true
    focus = false
    unless DimensionViewDetailsToggle.showing()
      $('.space-pictures, .dimensions').find('input').attr('name', '')
    if bool
      $("#design_space").submit()
    else
      $("#" + focus).focus()
      false

  SpacePicturesUploader.init()

class @DimensionViewDetailsToggle

  @init: ->
    @.refreshView(@.showing())

  @showing: ->
    $('[name="details_toggle"]:checked').val() is 'yes'

  @refreshView: (value)->
    showDetailsBlock = (value )
    $('.space-view-details').toggle(showDetailsBlock)
