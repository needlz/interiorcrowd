$(document).ready ->
  $("#login").submit ->
    $(".text-error").text ""
    username = $.trim($("#username").val())
    password = $.trim($("#password").val())
    bool = false
    if password.length < 1
      $("#err_p").text "Please enter password."
      bool = "password"
    if username.length < 1
      $("#err_u").text "Please enter email."
      bool = "username"
    if bool
      $("#" + bool).focus()
      false
    else
      true
