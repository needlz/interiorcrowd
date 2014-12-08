class @PortfolioEditor

  init: ->
    @bindYearsOfExpirience()
    @bindPictureUploaders()
    @bindSchoolCheckbox().trigger('change')

  bindYearsOfExpirience: ->
    $('#portfolio_years_of_expirience').keypress digitsFilter

  bindPictureUploaders: ->
    $('.portfolio-creation #portfolio_pictures').initUploaderWithThumbs(
      thumbs:
        container: '#portfolio_pictures_preview'
        selector: '#portfolio_pictures_ids'
      uploadify:
        buttonText: 'Upload'
        removeTimeout: 5
    )

    $('.portfolio-creation #personal_picture').initUploaderWithThumbs(
      thumbs:
        container: '#personal_picture_thumb'
        selector: '#personal_picture_id'
      uploadify:
        buttonText: 'Upload'
        removeTimeout: 5
        uploadLimit: 1
      single: true
    )

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
