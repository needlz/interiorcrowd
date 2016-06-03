class Validations

  continueButtonSelector: '.continueBtn'

  constructor: (@appealsCount)->
    @validator = new ValidationMessages()

  allAppealsSelected: ->
    $('.appeal .loveLikeLeave input:checked').length == @appealsCount

  validate: ->
    $('.text-error').text('')
    @validator.reset()

    unless @allAppealsSelected()
      @validator.addMessage $('#err-appeals'), I18n.validations.no_appeals, $('.appeal-options')

    fav_color = $.trim($('#fav_color').val())
    if fav_color.length < 1
      @validator.addMessage $('#err_fav'), I18n.validations.no_colors, $('.fav-colors')

  onSubmitClick: (e)=>
    e.preventDefault()

    @validate()
    if @validator.valid
      $('#design_style [type=submit]').click()
    else
      @validator.focusOnMessage()
      false

  init: ->
    $(@continueButtonSelector).click(@onSubmitClick)

class DesignStylePage

  @init: ->
    validations = new Validations(appealsCount)
    validations.init()

    DesirableColorsEditor.init()
    UndesirableColorsEditor.init()
    ExamplesUploader.init()
    InspirationLinksEditor.init()

    PicturesZoom.init('.appeal-picture-enlarge')

    mixpanel.track_forms '#design_style', 'Contest creation - Step 2', (form)->
      $form = $(form)
      { data: $form.serializeArray() }

$ ->
  DesignStylePage.init()
