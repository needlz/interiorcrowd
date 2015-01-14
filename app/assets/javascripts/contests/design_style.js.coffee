class Validations

  constructor: (@appealsCount, @levelContainer, @examplesToggle)->

  allAppealsSelected: ->
    $('.likes input:checked').length == @appealsCount

  clearHiddenInputs: ->
    $('.example-pictures, .links-options').find('input').attr('name', '') unless @examplesToggle.showing()

  validate: (errorCondition, validationMessage, text)->
    if errorCondition
      @valide = false
      validationMessage.text(text)
      @validationMessage = validationMessage unless @validationMessage

  init: ()->
    $(".slidercon input").slider()
    $(".continue").click (e) =>
      e.preventDefault()
      $(".text-error").text('')

      fav_color = $.trim($("#fav_color").val())
      refrain_color = $.trim($("#refrain_color").val())
      @valid = true
      @validationMessage = null

      @clearHiddenInputs()

      @validate fav_color.length < 1, $("#err_fav"), I18n.validations.no_colors
      @validate refrain_color.length < 1, $("#err_refrain"), I18n.validations.no_colors
      designerLevel = parseInt(@levelContainer.val())
      @validate isNaN(designerLevel), $("#err-designer-level"), I18n.validations.select_design_level
      @validate !@allAppealsSelected(), $("#err-appeals"), I18n.validations.no_appeals

      if @validationMessage
        false
        @validationMessage.get(0).scrollIntoView()
      else
        $("#design_style").submit()

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

    DesirableColorsEditor.init()
    UndesirableColorsEditor.init()
    AppealsForm.init()
    ExamplesUploader.init()
    inspirationLinksEditor = new InspirationLinksEditor()
    inspirationLinksEditor.init()

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
