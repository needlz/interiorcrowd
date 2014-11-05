$(document).on "click", ".lnk_container .plus_wrapper", ->
  $rows = $(".lnk_container:first").first()
  $formclone = $rows.clone()
  $formclone.find("input").val ""
  $formclone.insertAfter $(".lnk_container:last")
  $(".lnk_container .plus_wrapper").hide()
  $(".lnk_container .examplelabel label").hide()
  $(".lnk_container .examplelabel label").first().show()
  $(".lnk_container .minus_wrapper").show()  if $(".lnk_container .plus_wrapper").length > 1
  $(".lnk_container .plus_wrapper:last").last().show()
  return


#$('.particiapntForm:last').find('.frmdestroyer').show();
$(document).on "click", ".lnk_container .minus_wrapper", ->
  $(this).parent().parent().remove()
  $(".lnk_container .minus_wrapper").hide()  if $(".lnk_container .plus_wrapper").length is 1
  $(".lnk_container .plus_wrapper:last").last().show()
  $(".lnk_container .examplelabel label").hide()
  $(".lnk_container .examplelabel label").first().show()
  return

$(document).ready ->
  $(".continue").click (e) ->
    e.preventDefault()
    $(".text-error").html ""
    first_name = $.trim($("#designer_first_name").val())
    last_name = $.trim($("#designer_last_name").val())
    email = $.trim($("#designer_email").val())
    password = $.trim($("#designer_password").val())
    c_password = $.trim($("#designer_password_confirmation").val())
    zip = $.trim($("#designer_zip").val())
    bool = false
    if zip.length > 1
      unless $.isNumeric(zip)
        $("#err_zip").text "Please enter valid zip."
        bool = "designer_zip"
    else
      $("#err_zip").text "Please enter zip."
      bool = "designer_zip"
    if password.length < 1
      $("#err_password").text "Please enter paswword."
      bool = "designer_password"
    if c_password.length < 1
      $("#err_cpassword").text "Please enter confirm paswword."
      bool = "designer_password_confirmation"
    else
      unless c_password is password
        $("#err_cpassword").text "Password and Confirm password must be same."
        bool = "designer_password_confirmation"
    if email.length > 1
      rege = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/
      unless rege.test(email)
        $("#err_email").text "Please enter valid email."
        bool = "designer_email"
    else
      $("#err_email").text "Please enter email."
      bool = "designer_email"
    if last_name.length < 1
      $("#err_last_name").text "Please enter last name."
      bool = "designer_last_name"
    if first_name.length < 1
      $("#err_first_name").text "Please enter first name."
      bool = "designer_first_name"
    if bool
      $("#" + bool).focus()
      false
    else
      can_submit = true
      $(".des_links").each ->
        url_value = $.trim($(this).val())
        if url_value.length > 1
          rege = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
          unless rege.test(url_value)
            $(this).removeClass("alert-danger").addClass "alert-danger"
            can_submit = false
        return

      if can_submit
        $("#new_designer").submit()
        true
      else
        alert "Please enter valid Link URL and make sure to add prefix http or https in URL"
        false

  $("#file_input").initUploader
    buttonText: "Upload"
    removeTimeout: 3
    onUploadSuccess: (file, data, response) ->
      info = data.split(",")
      $("#image_display").append "<img src='" + info[0] + "' />"
      img_val = $.trim($("#designer_image").val())
      img_id = $.trim($("#designer_ex_document_ids").val())
      if img_val.length < 1
        $("#designer_image").val info[0]
        $("#designer_ex_document_ids").val info[1]
      else
        $("#designer_image").val img_val + "," + info[0]
        $("#designer_ex_document_ids").val img_id + "," + info[1]


  $.each(exlnks, (index, link)->
    $rows = $(".lnk_container:first").first()
    $formclone = $rows.clone()
    $formclone.find("input").val "<%= link %>"
    $formclone.insertBefore $(".lnk_container:last")
    $(".lnk_container .plus_wrapper").hide()
    $(".lnk_container .examplelabel label").hide().first().show()
    $(".lnk_container .minus_wrapper").show() if $(".lnk_container .plus_wrapper").length > 1
    $(".lnk_container .plus_wrapper:last").last().show()
  )
