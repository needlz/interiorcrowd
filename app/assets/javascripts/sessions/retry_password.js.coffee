$(document).ready ->
  $("#login").submit ->
    $("#err_f").text ""
    email = $("#email").val().trim()
    bool = true
    if email.length > 0
      regex = window.emailRegex
      unless regex.test(email)
        $("#err_f").text "Please enter valid email."
        bool = false
    else
      $("#err_f").text "Please enter email."
      bool = false
    false  unless bool

  mixpanel.track_forms '#reset-password', 'Password reset'
