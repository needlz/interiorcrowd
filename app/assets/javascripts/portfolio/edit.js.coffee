class @PortfolioEditor

  init: ->
    @bindYearsOfExpirience()
    @bindPictureUploaders()
    @bindSchoolCheckbox().trigger('change')

    $(".selectpicker").selectpicker style: "btn-selector-medium font15"
    $(".dropdown-toggle").click ->
      $(this).next(".dropdown-menu").toggle()

    $("ul.dropdown-menu li").click ->
      $(this).parent().parent().parent().find("div.dropdown-menu").toggle()

    $(".pull-down").each ->
      $(this).css "margin-top", $(this).parent().height() - $(this).height()

    $('#portfolio_education_school').change (event)->
      $('#sub1').toggleClass('active', $('#portfolio_education_school').is(':checked'));

    $(".tick-btn").click ->
      $(this).toggleClass "active"
      $checkbox = $(this).prev(':checkbox')
      $checkbox.prop('checked', $(this).hasClass('active'))
      $checkbox.change()

    $(".spinner .btn:first-of-type").on "click", (event)->
      $(".spinner input").val(parseInt($(".spinner input").val(), 10) + 1)
      event.preventDefault()

    $(".spinner .btn:last-of-type").on "click", (event)->
      value = parseInt($(".spinner input").val(), 10)
      $(".spinner input").val(value - 1) if value >= 1
      event.preventDefault()

    $('.hidden:checkbox').change (event)->
      $checkbox = $(@)
      $checkbox.next('.tick-btn').toggleClass('active', $checkbox.is(':checked'))
    $('.hidden:checkbox').change()

  bindYearsOfExpirience: ->
    $('#portfolio_years_of_expirience').keypress digitsFilter

  bindPictureUploaders: ->
    PicturesUploadButton.init
      I18n: I18n.upload_pictrures
      fileinputSelector: '#portfolio_pictures'
      uploadButtonSelector: '.uploaded-images .upload-button'
      thumbs:
        container: '#portfolio_pictures_preview .container'
        selector: '#portfolio_pictures_ids'
        theme: 'new'

    PicturesUploadButton.init
      I18n: I18n.upload_personal_picture
      fileinputSelector: '#personal_picture'
      uploadButtonSelector: '.personal-picture .upload-button'
      single: true
      thumbs:
        container: '.personal-picture .thumbs'
        selector: '.personal-picture #personal_picture_id'
        theme: 'new'

  bindSchoolCheckbox: ->
    handler = (event)=>
      $checkbox = $(event.target)
      $('#school-details').toggle($checkbox.is(':checked'))
    $checkbox = $('#portfolio_education_school')
    $checkbox.change(handler)
    $checkbox

$ ->
  portfolioEditor = new PortfolioEditor()
  portfolioEditor.init()
