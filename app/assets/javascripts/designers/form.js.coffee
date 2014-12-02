class @DesignerSignUp

  init: ->
    @bindEvents()
    @populateExamplesInputs()

  bindEvents: ->
    @bindAddLinkButton()
    @bindRemoveLinkButton()
    @bindCreateAccountButton()
    @bindFileUploader()
    $('#designer_zip').keypress digitsFilter

  bindAddLinkButton: ->
    $(document).on 'click', '.lnk_container .plus_wrapper', @, (event)->
      $rows = $('.lnk_container:first').first()
      $formclone = $rows.clone()
      $formclone.find('input').val ''
      $formclone.insertAfter $('.lnk_container:last')
      signUp = event.data
      signUp.refreshLinkButtons('added')

  bindRemoveLinkButton: ->
    $(document).on 'click', '.lnk_container .minus_wrapper', @, (event)->
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
      if @invalidInputs.length
        $(@invalidInputs).first().focus()
        false
      else
        can_submit = true
        $('.des_links').each (index, input) =>
          url_value = $.trim($(input).val())
          if url_value.length > 1
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

  bindFileUploader: ->
    $('#file_input').initUploaderWithThumbs
      thumbs:
        container: '#image_display'
        selector: '#designer_ex_document_ids'
      uploadify:
        buttonText: I18n.upload_example_button
        removeTimeout: 3

  validLink: (link)->
    regex = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
    regex.test(link)

  validEmail: (email)->
    regex = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/
    regex.test(email)

  validations:
    designer_first_name: ->
      $('#err_first_name').text(I18n.validation_messages.enter_first_name) if @designer_first_name.length < 1
    designer_last_name: ->
      $('#err_last_name').text(I18n.validation_messages.enter_last_name) if @designer_last_name.length < 1
    designer_email: ->
      if @designer_email.length > 1
        $('#err_email').text I18n.validation_messages.invalid_email unless @validEmail(@designer_email)
      else
        $('#err_email').text I18n.validation_messages.enter_email
    designer_zip: ->
      if @designer_zip.length > 1
        $('#err_zip').text 'Please enter valid zip.' unless $.isNumeric(@designer_zip)
      else
        $('#err_zip').text 'Please enter zip.'
    designer_password: ->
      $('#err_password').text I18n.validation_messages.enter_password if @designer_password.length < 1
    designer_password_confirmation: ->
      if @designer_password_confirmation.length < 1
        $('#err_cpassword').text I18n.validation_messages.confirm_password
      else
        unless @designer_password_confirmation is @designer_password
          $('#err_cpassword').text I18n.validation_messages.password_confirmation_mistmatch

  validateInputs: ->
    $('.text-error').text ''
    @readInputValues()
    @invalidInputs = []
    for inputId, validation of @validations
      @validateInput($('#' + inputId), validation)

  readInputValues: ->
    for inputId of @validations
      $input = $('#' + inputId)
      @[inputId] = $.trim($input.val())

  validateInput: ($input, validation)->
    errors = validation.apply(@)
    @invalidInputs.push($input) if errors

$(document).ready ->
  signUp = new DesignerSignUp()
  signUp.init()

