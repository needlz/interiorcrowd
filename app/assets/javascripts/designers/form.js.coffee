class @DesignerSignUp

  init: ->
    @bindEvents()
    @populateExamplesInputs()
    @validator = new ValidationMessages()

  bindEvents: ->
    @bindAddLinkButton()
    @bindRemoveLinkButton()
    @bindCreateAccountButton()
    @bindFileUploader()
    $('#designer_zip').keypress digitsFilter

    $('.selectpicker').selectpicker({
      style: 'btn-selector-medium font15'
    });

    $(".tick-btn").click (e)->
      $(@).toggleClass "active"
      $('#designer_agree').prop('checked', $(@).hasClass('active'))

  bindAddLinkButton: ->
    $(document).on 'click', '.lnk_container .plus_wrapper', @, (event)->
      event.preventDefault()
      $rows = $('.lnk_container:first').first()
      $formclone = $rows.clone()
      $formclone.find('input').val ''
      $formclone.insertAfter $('.lnk_container:last')
      signUp = event.data
      signUp.refreshLinkButtons('added')

  bindRemoveLinkButton: ->
    $(document).on 'click', '.lnk_container .minus_wrapper', @, (event)->
      event.preventDefault()
      $(event.target).parents('.lnk_container').remove()
      signUp = event.data
      signUp.refreshLinkButtons('removed')

  populateExamplesInputs: ->
    $.each(externaLinks, (index, link)=>
      $rows = $('.lnk_container:first').first()
      $formclone = $rows.clone()
      $formclone.find('input').val link
      $formclone.insertBefore $('.lnk_container:last')
      @refreshLinkButtons('added')
    )

  refreshLinkButtons: (change)->
    if change is 'added'
      $('.lnk_container .plus_wrapper').hide()
      $('.lnk_container .examplelabel label').hide().first().show()
      $('.lnk_container .minus_wrapper').show() if $('.lnk_container .plus_wrapper').length > 1
      $('.lnk_container .plus_wrapper:last').last().show()
    else if change is 'removed'
      $('.lnk_container .minus_wrapper').hide()  if $('.lnk_container .plus_wrapper').length is 1
      $('.lnk_container .plus_wrapper:last').last().show()
      $('.lnk_container .examplelabel label').hide()
      $('.lnk_container .examplelabel label').first().show()

  bindCreateAccountButton: ->
    $('.create-account').click (e) =>
      e.preventDefault()
      @validateInputs()
      if @validator.valid
        can_submit = true
        $('.des_links').each (index, input) =>
          url_value = $.trim($(input).val())
          if url_value.length
            unless @validLink(url_value)
              $(this).removeClass('alert-danger').addClass 'alert-danger'
              can_submit = false
          return
        if can_submit
          $('#new_designer').submit()
          true
        else
          alert I18n.validation_messages.invalid_example_url
          false
      else
        @validator.focusOnMessage()
        false

  bindFileUploader: ->
    PicturesUploadButton.init
      fileinputSelector: '#new_designer #file_input',
      uploadButtonSelector: '#new_designer .upload-button',
      thumbs:
        container: '#image_display'
        selector: '#designer_image'
        theme: 'new'
      I18n: I18n.examples

  validLink: (link)->
    regex = /((ftp|http|https):\/\/)?(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
    regex.test(link)

  validEmail: (email)->
    regex = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/
    regex.test(email)

  validations:
    designer_first_name: ->
      if @designer_first_name.length < 1
        @validator.addMessage $('#err_first_name'), I18n.validation_messages.enter_first_name, $('#err_first_name')
    designer_last_name: ->
      if @designer_last_name.length < 1
        @validator.addMessage $('#err_last_name'), I18n.validation_messages.enter_last_name, $('#err_last_name')
    designer_email: ->
      if @designer_email.length > 1
        unless @validEmail(@designer_email)
          @validator.addMessage $('#err_email'), I18n.validation_messages.invalid_email, $('#err_email')
      else
        @validator.addMessage $('#err_email'), I18n.validation_messages.enter_email, $('#err_email')
    designer_zip: ->
      if @designer_zip.length > 1
        unless $.isNumeric(@designer_zip)
          @validator.addMessage $('#err_zip'), 'Please enter valid zip.', $('#err_zip')
      else
        @validator.addMessage $('#err_zip'), 'Please enter zip.', $('#err_zip')
    designer_password: ->
      if @designer_password.length < 1
        @validator.addMessage $('#err_password'), I18n.validation_messages.enter_password, $('#err_password')
    designer_password_confirmation: ->
      if @designer_password_confirmation.length < 1
        @validator.addMessage $('#err_cpassword'), I18n.validation_messages.confirm_password, $('#err_cpassword')
      else
        unless @designer_password_confirmation is @designer_password
          @validator.addMessage $('#err_cpassword'), I18n.validation_messages.password_confirmation_mistmatch, $('#err_cpassword')
    designer_agree: ->
      unless $('#designer_agree').is(':checked')
        @validator.valid = false

  validateInputs: ->
    $('.text-error').text ''
    @validator.reset()
    @readInputValues()
    for inputId, validation of @validations
      @validateInput($('#' + inputId), validation)

  readInputValues: ->
    for inputId of @validations
      $input = $('#' + inputId)
      @[inputId] = $.trim($input.val())

  validateInput: ($input, validation)->
    validation.apply(@)

$(document).ready ->
  signUp = new DesignerSignUp()
  signUp.init()

