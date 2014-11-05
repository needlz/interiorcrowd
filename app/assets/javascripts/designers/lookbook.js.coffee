$ ->
  $(".continue").click (e) ->
    e.preventDefault()
    $(".text-error").html ""
    bool = false
    can_submit = false
    $(".link_url").each ->
      url_value = $.trim($(this).val())
      if url_value.length > 1
        rege = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
        unless rege.test(url_value)
          bool = true
          $(this).removeClass("alert-danger").addClass "alert-danger"
        else
          can_submit = true

    if bool
      alert "Please enter valid Link URL and make sure to add prefix http or https in URL"
      false
    else
      if can_submit
        $("#lookbook").submit()
        true
      else
        if $("[name='picture[urls][]'],[name='link[urls][]']").length > 0
          $("#lookbook").submit()
          true
        else
          alert "Please add atleast one picture or Link."
          false

  $("#file_input").initUploader
    buttonText: "Upload"
    removeTimeout: 10
    onUploadSuccess: (file, data, response) ->
      info = data.split(",")
      url = info[0]
      image_id = info[1]
      $("#image_display").append """
        <div class='col-sm-8 img_img_box' style='padding-top:20px;'>
          <div class='img' style='width:50%;float:left'>
            <img src='#{ info[0] }' />
          </div>
          <label style='float:left'>Add text to go at bottom of image</br>
            <input name='picture[titles][]' type='text' style='width:100%' maxlength='100'>
            <input name='picture[urls][]' type='hidden' value='#{ url }'>
            <input name='picture[ids][]' type='hidden' value='#{ image_id }'>
          </label>
        </div>
"""


$(document).on "click", ".img_container .plus_wrapper", ->
  $rows = $(".img_container:first").first()
  $formclone = $rows.clone()
  $formclone.find("input").val ""
  $formclone.find(".img_img_box").hide()
  $formclone.insertAfter $(".img_container:last")
  $(".img_container .plus_wrapper").hide()
  $(".img_container .minus_wrapper").show() if $(".img_container .plus_wrapper").length > 1
  $(".img_container .plus_wrapper:last").last().show()

$(document).on "click", ".img_container .minus_wrapper", ->
  $(this).parent().parent().remove()
  $(".img_container .minus_wrapper").hide() if $(".img_container .plus_wrapper").length is 1
  $(".img_container .plus_wrapper:last").last().show()

$(document).on "click", ".lnk_container .plus_wrapper", ->
  $rows = $(".lnk_container:first").first()
  $formclone = $rows.clone()
  $formclone.find("input").val ""
  $formclone.find(".lnk_img_box").hide()
  $formclone.insertAfter $(".lnk_container:last")
  $(".lnk_container .plus_wrapper").hide()
  $(".lnk_container .minus_wrapper").show() if $(".lnk_container .plus_wrapper").length > 1
  $(".lnk_container .plus_wrapper:last").last().show()

$(document).on "click", ".lnk_container .minus_wrapper", ->
  $(this).parent().parent().remove()
  $(".lnk_container .minus_wrapper").hide() if $(".lnk_container .plus_wrapper").length is 1
  $(".lnk_container .plus_wrapper:last").last().show()