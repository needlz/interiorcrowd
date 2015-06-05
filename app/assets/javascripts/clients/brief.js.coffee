class @ContestEditing extends InlineEditor

  attributeIdentifierData: 'option'
  placeholderSelector: '.attribute-form'
  attributeSelector: '.attribute'

  bindEvents: ->
    super()
    @bindSaveClick()
    @bindSaveSuccess()
    @bindSaveError()
    @initPreview()

  initPreview: ->
    $(@attributeSelector).filter("[data-#{ @attributeIdentifierData }]").each((index, element)=>
      attribute = $(element).data(@attributeIdentifierData)
      @previewCallbacks[attribute]?()
    )

  bindSaveClick: ->
    $('body').on('click', "#{ @attributeSelector } .save-button", @onSaveClick)

  bindSaveSuccess: ->
    $('body').on('ajax:success', "#{ @attributeSelector } form", (event, data, status, xhr)=>
      $form = $(event.target)
      option = $form.parents('[data-option]').data('option')
      mixpanel.track('Contest edited', { attributes: option })
      $editButton = $("#{ @attributeSelector }[data-option='#{ option }'] .cancel-button")
      $optionsRow = @optionsRow($editButton)
      @cancelEditing($optionsRow.data(@attributeIdentifierData))
      $optionsRow.find('.preview').html(data)
      @previewCallbacks[option]?()
    )

  bindSaveError: ->
    $('body').on('ajax:error', "#{ @attributeSelector } form", (event, data, status, xhr)=>
      $form = $(event.target)
      @optionsContainer($form).find('.has-error .control-label').text 'An error occured during saving'
    )

  getForm: (attribute)->
    $.ajax(
      data: { option: attribute }
      url: @formHtmlPath()
      success: (formHtml)=>
        @onEditFormRetrieved(attribute, formHtml)
    )

  contestId: ->
    $('.contest').data('id')

  optionsContainer: ($childElement)->
    @optionsRow($childElement).find('.attribute-form .view')

  formHtmlPath: ->
    "/contests/#{ @contestId() }/option"

  afterEditFormRetrieved: (attribute, formHtml)->
    $saveButton = $("[data-option=#{ attribute }]").find('.save-button')
    $saveButton.show()

  editFormsCallbacks:
    space_pictures: ->
      SpacePicturesUploader.init(I18n.contests.space.photos)
    example_pictures: ->
      ExamplesUploader.init()
    desirable_colors: ->
      DesirableColorsEditor.init()
    undesirable_colors: ->
      UndesirableColorsEditor.init()
    area: ->
      RoomsEditor.init()
    example_links: ->
      InspirationLinksEditor.init()
    space_dimensions: ->
      DesignSpaceOptions.bindInchesInputs()
    design_package: ->
      Packages.init()
    feedback: ->
      DesignSpaceOptions.init(feedbackPlaceholder: I18n.contests.space.other_feedback.placeholder)

  previewCallbacks:
    desirable_colors: ->
      ContestPreview.initColorPickers()
    undesirable_colors: ->
      ContestPreview.initColorPickers()
    design_profile: ->
      ContestPreview.initStyleCollagesZooming()
      ContestPreview.initStyleDetailsPopups()
    space_pictures: ->
      PicturesZoom.initGallery(enlargeButtonSelector: '[data-option=space_pictures] a.enlarge', galleryName: 'space')
    example_pictures: ->
      PicturesZoom.initGallery(enlargeButtonSelector: '[data-option=example_pictures] a.enlarge', galleryName: 'examples')

  onSaveClick: (event)=>
    $saveButton = $(event.target)
    $saveButton.parents('form').find($.rails.fileInputSelector).remove()
    $saveButton.parents('form').trigger('submit.rails');

  updateEditButton: ($elem)->
    $editButton = $('.edit-button.template').html()
    $elem.html($editButton)

$ ->
  window.brief = new ContestEditing()
  brief.bindEvents()
