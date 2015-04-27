$(document).ready ->
  $("#login").submit ->
    $("#err_f").text ""
    email = $("#email").val().trim()
    bool = true
    if email.length > 0
      rege = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/
      unless rege.test(email)
        $("#err_f").text "Please enter valid email."
        bool = false
    else
      $("#err_f").text "Please enter email."
      bool = false
    false  unless bool

  mixpanel.tracke_forms '#reset-password', 'Password reset'
