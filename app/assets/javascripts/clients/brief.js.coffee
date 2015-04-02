class @ContestEditing extends InlineEditor

  attributeIdentifierData: 'option'
  placeholderSelector: '.attribute-form'
  attributeSelector: '.edit-profile'

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
    $('body').on('click', '.edit-profile .save-button', @onSaveClick)

  bindSaveSuccess: ->
    $('body').on('ajax:success', '.edit-profile form', (event, data, status, xhr)=>
      $form = $(event.target)
      option = $form.parents('[data-option]').data('option')
      $editButton = $(".edit-profile[data-option='#{ option }'] .cancel-button")
      $optionsRow = @optionsRow($editButton)
      @cancelEditing($optionsRow.data(@attributeIdentifierData))
      $optionsRow.find('.preview').html(data)
      @previewCallbacks[option]?()
    )

  bindSaveError: ->
    $('body').on('ajax:error', '.edit-profile form', (event, data, status, xhr)=>
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
    budget: ->
      BudgetOptions.init()
    example_links: ->
      InspirationLinksEditor.init()
    space_dimensions: ->
      DesignSpacePage.bindInchesInputs()
    design_package: ->
      Packages.init()

  previewCallbacks:
    desirable_colors: ->
      ContestPreview.init()
    undesirable_colors: ->
      ContestPreview.init()
    design_profile: ->
      PicturesZoom.init('.imageWithOverlay a')
    space_pictures: ->
      PicturesZoom.initGallery(buttonSelector: '[data-option=space_pictures] a', galleryName: 'space')
    example_pictures: ->
      PicturesZoom.initGallery(buttonSelector: '[data-option=example_pictures] a', galleryName: 'examples')

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
