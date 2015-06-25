class Validations

  continueButtonSelector: '.continueBtn'

  constructor: (@appealsCount, @levelContainer)->
    @validator = new ValidationMessages()

  allAppealsSelected: ->
    $('.appeal .loveLikeLeave input:checked').length == @appealsCount

  validate: ->
    $('.text-error').text('')
    @validator.reset()

    unless @levelContainer.filter(':checked').length
      @validator.addMessage $("#err-designer-level"), I18n.validations.select_design_level, $('.designer-levels')

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
    $levelContainer = $("input[name='design_style[designer_level]']")
    validations = new Validations(appealsCount, $levelContainer)
    validations.init()

    DesirableColorsEditor.init()
    UndesirableColorsEditor.init()
    ExamplesUploader.init()
    InspirationLinksEditor.init()

    @bindDesignLevelItems($levelContainer)

    PicturesZoom.init('.appeal-picture-enlarge')

    mixpanel.track_forms '#design_style', 'Contest creation - Step 2', (form)->
      $form = $(form)
      { data: $form.serializeArray() }

  @bindDesignLevelItems: ($levelContainer)->
    $('.interiorDesignLevel input:radio').change (event)->
      $radio = $(event.target)
      console.log $radio.data('name')
      $('.interiorDesignLevelMobile div').removeClass('active')
      if $radio.is(':checked')
        $('.interiorDesignLevelMobile label').filter('.' + $radio.data('name')).parent().addClass('active')

$ ->
  DesignStylePage.init()
