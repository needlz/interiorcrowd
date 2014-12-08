class @PortfolioEditor

  init: ->
    @bindYearsOfExpirience()
    @bindPictureUploaders()
    @bindSchoolCheckbox()
    @updateSchoolDetails(@$education_school_checkbox())

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
    @$education_school_checkbox().change (event)=>
      $checkbox = $(event.target)
      @updateSchoolDetails($checkbox)

  updateSchoolDetails: ($school_checkbox)->
    if $school_checkbox.is(':checked')
      $('#school-details').show()
    else
      $('#school-details').hide()

  $education_school_checkbox: ->
    $('#portfolio_education_school')

$ ->
  portfolioEditor = new PortfolioEditor()
  portfolioEditor.init()
