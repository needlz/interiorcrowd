$(document).ready ->
  $(".continue").click (e) ->
    e.preventDefault()
    $(".text-error").html ""
    first_name = $.trim($("#client_first_name").val())
    last_name = $.trim($("#client_last_name").val())
    email = $.trim($("#client_email").val())
    password = $.trim($("#client_password").val())
    c_password = $.trim($("#client_password_confirmation").val())
    name_on_card = $.trim($("#client_name_on_card").val())
    address = $.trim($("#client_address").val())
    state = $.trim($("#client_state").val())
    zip = $.trim($("#client_zip").val())
    card_type = $.trim($(".card_type:checked").val())
    cvc = $.trim($("#card_cvc").val())
    bool = false
    if cvc.length > 1
      $("#err_cvc").text "Please enter valid CVC, must have 3 digits."  if not $.isNumeric(cvc) or cvc.length isnt 3
    else
      $("#err_cvc").text "Please enter CVC."
      bool = "card_cvc"
    if $("#card_number").val().length < 1
      $("#err_card_number").text "Please enter card number."
      bool = "card_number"
    else
      $("#card_number").validateCreditCard (result) ->
        if result.card_type
          unless result.card_type.name is card_type and result.length_valid
            $("#err_card_number").text "Please enter valid card number."
            bool = "card_number"
        else
          $("#err_card_number").text "Please enter valid card number."
          bool = "card_number"

    if zip.length > 1
      unless $.isNumeric(zip)
        $("#err_zip").text "Please enter valid zip."
        bool = "user_zip"
    else
      $("#err_zip").text "Please enter zip."
      bool = "user_zip"
    if state.length > 1
      rege = /^[a-zA-Z]+$/
      unless rege.test(state)
        $("#err_state").text "Please enter valid state. Only letters are allowed."
        bool = "user_state"
    else
      $("#err_state").text "Please enter state."
      bool = "user_state"
    if address.length < 1
      $("#err_address").text "Please enter address."
      bool = "user_address"
    if name_on_card.length < 1
      $("#err_name_on_card").text "Please enter name."
      bool = "user_name_on_card"
    if password.length < 1
      $("#err_password").text "Please enter paswword."
      bool = "user_password"
    if c_password.length < 1
      $("#err_cpassword").text "Please enter confirm paswword."
      bool = "user_password_confirmation"
    else
      unless c_password is password
        $("#err_cpassword").text "Password and Confirm password must be same."
        bool = "user_password_confirmation"
    if email.length > 1
      rege = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/
      unless rege.test(email)
        $("#err_email").text "Please enter valid email."
        bool = "user_email"
    else
      $("#err_email").text "Please enter email."
      bool = "user_email"
    if last_name.length < 1
      $("#err_last_name").text "Please enter last name."
      bool = "user_last_name"
    if first_name.length < 1
      $("#err_first_name").text "Please enter first name."
      bool = "user_first_name"
    if bool
      $("#" + bool).focus()
      false
    else
      $("#new_client").submit()
      true
