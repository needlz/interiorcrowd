$ ->
  $(".continue").click (e) ->
    $("#new_contest_request").submit()

  $("#file_input").initUploader
    buttonText: "Upload a design"
    removeTimeout: 3
    onUploadSuccess: (file, data, response) ->
      info = data.split(",")
      $("#image_display").append "<img src='" + info[0] + "' />"
      img_id = $.trim($("#contest_request_designs").val())
      if img_id.length < 1
        $("#contest_request_designs").val info[1]
      else
        $("#contest_request_designs").val img_id + "," + info[1]
