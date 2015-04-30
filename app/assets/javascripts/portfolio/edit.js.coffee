class CoverImage

  @idInput: '#portfolio_background_id'

  @toggle: ($thumb)->
    @deselectAll()
    if $thumb.data('id') == parseInt($(@idInput).val())
      $(@idInput).val('')
    else
      @select($thumb)

  @select: ($thumb)->
    $thumb.addClass('active')
    @setCover($thumb.data('id'))

  @deselectAll: ->
    $('.portfolio-item').removeClass('active')

  @setCover: (id)->
    $(@idInput).val(id)

  @id: ->
    $(@idInput).val()

class @PortfolioEditor

  init: ->
    @bindYearsOfExperience()
    @bindPictureUploaders()
    @bindSchoolCheckbox().trigger('change')
    PopulatedInputs.init()
    @bindCheckboxes()
    @bindImageCoverButtons()

    $(".selectpicker").selectpicker style: "btn-selector-medium font15"
    $(".dropdown-toggle").click ->
      $(this).next(".dropdown-menu").toggle()

    $("ul.dropdown-menu li").click ->
      $(this).parent().parent().parent().find("div.dropdown-menu").toggle()

    mixpanel.track_forms '.edit_portfolio', 'Portfolio edited', (form)->
      { designer_id: $(form).data('designer-id') }

  bindImageCoverButtons: ->
    $('#portfolio_pictures_preview').on 'click', '.cover-button', (event)->
      event.preventDefault()
      $selectButton = $(@)
      $selectedThumb = $selectButton.parents('.portfolio-item')
      CoverImage.toggle($selectedThumb)

  bindCheckboxes: ->
    $('#portfolio_education_school').change (event)->
      $('#sub1').toggleClass('active', $('#portfolio_education_school').is(':checked'));

    StyledCheckboxes.init(styledCheckboxSelector: '.tick-btn')

  bindYearsOfExperience: ->
    $('#portfolio_years_of_experience').ForceNumericOnly();

    $(".spinner .btn:first-of-type").on "click", (event)->
      value = ~~$(".spinner input").val()
      $(".spinner input").val(value + 1)
      event.preventDefault()

    $(".spinner .btn:last-of-type").on "click", (event)->
      value = ~~$(".spinner input").val()
      value = value - 1 if value >= 1
      $(".spinner input").val(value)
      event.preventDefault()

  bindPictureUploaders: ->
    PicturesUploadButton.init
      I18n: I18n.upload_pictrures
      fileinputSelector: '#portfolio_pictures'
      uploadButtonSelector: '.uploaded-images .upload-button'
      thumbs:
        container: '#portfolio_pictures_preview .container'
        selector: '#portfolio_pictures_ids'
        theme: RemovableThumbsTheme
        onRemoved: @onPictureRemoved

    PicturesUploadButton.init
      I18n: I18n.upload_personal_picture
      fileinputSelector: '#personal_picture'
      uploadButtonSelector: '.personal-picture .upload-button'
      single: true
      thumbs:
        container: '.personal-picture .thumbs'
        selector: '.personal-picture #personal_picture_id'
        theme: RemovableThumbsTheme

  bindSchoolCheckbox: ->
    handler = (event)=>
      $checkbox = $(event.target)
      $('#school-details').toggle($checkbox.is(':checked'))
    $checkbox = $('#portfolio_education_school')
    $checkbox.change(handler)
    $checkbox

  onPictureRemoved: (pictureId)->
    if `pictureId == CoverImage.id()`
      CoverImage.setCover('')

$ ->
  portfolioEditor = new PortfolioEditor()
  portfolioEditor.init()
