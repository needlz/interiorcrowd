class Validations

  constructor: (@appealsCount, @levelContainer, @examplesToggle)->
    @validator = new ValidationMessages()

  allAppealsSelected: ->
    $('.likes input:checked').length == @appealsCount

  clearHiddenInputs: ->
    $('.example-pictures, .links-options').find('input').attr('name', '') unless @examplesToggle.showing()

  validate: ->
    $(".text-error").text('')
    @validator.reset()

    designerLevel = parseInt(@levelContainer.val())
    if isNaN(designerLevel)
      @validator.addMessage $("#err-designer-level"), I18n.validations.select_design_level, $('.designer-levels')

    unless @allAppealsSelected()
      @validator.addMessage $("#err-appeals"), I18n.validations.no_appeals, $('.appeal-options')

    fav_color = $.trim($("#fav_color").val())
    if fav_color.length < 1
      @validator.addMessage $("#err_fav"), I18n.validations.no_colors, $(".fav-colors")

  onSubmitClick: (e)=>
    e.preventDefault()

    @validate()
    if @validator.valid
      @clearHiddenInputs()
      $("#design_style").submit()
    else
      @validator.focusOnMessage()
      false


  init: ->
    $(".continue").click(@onSubmitClick)

class DesignStylePage

  @init: ->
    $levelContainer = $("input[name='design_style[designer_level]']")
    examplesToggle = new OptionsContainerToggle(
      radioButtonsSelector: '[name="examples_toggle"]',
      containerSelector: '.examples-view-details'
    )
    examplesToggle.init()
    validations = new Validations(appealsCount, $levelContainer, examplesToggle)
    validations.init()

    $(".slidercon input").slider()

    DesirableColorsEditor.init()
    UndesirableColorsEditor.init()
    AppealsForm.init()
    ExamplesUploader.init()
    InspirationLinksEditor.init()

    @bindDesignLevelItems($levelContainer)

  @bindDesignLevelItems: ($levelContainer)->
    $('.level-block').click (event)=>
      $selectedLevel = $(event.target).closest('.level-block')
      newId = $selectedLevel.data('id')
      $levelContainer.val(newId)
      $('.level-block').removeClass('active')
      $('.level-block').find('.check').hide()
      $selectedLevel.addClass('active')
      $selectedLevel.find('.check').show()

$ ->
  DesignStylePage.init()
