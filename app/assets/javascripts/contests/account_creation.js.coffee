class AccountCreation

  @init: ->
    @validator = new ValidationMessages()
    Promocode.init()
    @bindSubmitButton()
    @bindAgreementCheckbox()
    @bindNumericInputs()

  @bindNumericInputs: ->
    $('#card_number, #card_cvc, #client_zip').ForceNumericOnly()

  @validations: [
    ->
      $first_name = $("#client_first_name")
      if trimedVal($first_name).length < 1
        @validator.addMessage $("#err_first_name"), "Please enter first name.", $first_name
    ->
      $last_name = $("#client_last_name")
      if trimedVal($last_name).length < 1
        @validator.addMessage $("#err_last_name"), "Please enter last name.", $last_name
    ->
      $email = $("#client_email")
      email = trimedVal($email)
      if email.length > 1
        rege = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/
        unless rege.test(email)
          @validator.addMessage $("#err_email"), "Please enter valid email.", $email
      else
        @validator.addMessage $("#err_email"), "Please enter email.", $email
    ->
      $password = $("#client_password")
      password = trimedVal($password)
      if password.length < 1
        @validator.addMessage $("#err_password"), "Please enter password.", $password
      $c_password = $("#client_password_confirmation")
      c_password = trimedVal($c_password)
      if c_password.length < 1
        @validator.addMessage $("#err_cpassword"), "Please enter confirm password.", $c_password
      else
        unless c_password is password
          @validator.addMessage $("#err_cpassword"), "Password and Confirm password must be same.", $c_password
    ->
      unless $('#client_agree').is(':checked')
        @validator.valid = false
  ]

  @validate: ->
    @validator.reset()
    for validation in @validations
      validation.apply @

  @bindSubmitButton: ->
    $('.submit-button').click (e) =>
      e.preventDefault()
      $('.text-error').html('')
      @validate()
      if @validator.valid
        fbq('track', 'CompleteRegistration')
        setTimeout(
          =>
            $('#new_client [type=submit]').click()
          200
        )
      else
        @validator.focusOnMessage()
        false

  @bindAgreementCheckbox: ->
    $('.tick-btn').click ->
      $(this).toggleClass 'active'
      $('#client_agree').trigger 'click'

$(document).ready ->
  AccountCreation.init()
