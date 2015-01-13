class Validations

  constructor: (@appealsCount, @levelContainer, @examplesToggle)->

  allAppealsSelected: ->
    $('.likes input:checked').length == @appealsCount

  clearHiddenInputs: ->
    $('.example-pictures, .links-options').find('input').attr('name', '') unless @examplesToggle.showing()

  init: ()->
    $(".slidercon input").slider()
    $(".continue").click (e) =>
      e.preventDefault()
      $(".text-error").html ""
      fav_color = $.trim($("#fav_color").val())
      refrain_color = $.trim($("#refrain_color").val())
      valid = true
      @clearHiddenInputs()
      if fav_color.length < 1
        valid = false
        $("#err_fav").html I18n.validations.no_colors
      if refrain_color.length < 1
        valid = false
        $("#err_refrain").html I18n.validations.no_colors
      if isNaN(parseInt(@levelContainer.val()))
        valid = false
        $("#err-designer-level").html I18n.validations.select_design_level
      unless @allAppealsSelected()
        valid = false
        $("#err-appeals").html I18n.validations.no_appeals
      if valid
        $("#design_style").submit()
      else
        false

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
