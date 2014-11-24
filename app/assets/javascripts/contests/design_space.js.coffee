$ ->
  $(".continue").click (e) ->
    e.preventDefault()
    $(".text-error").html ""
    f_length = $.trim($("#length_feet").val())
    i_length = $.trim($("#length_inches").val())
    f_width = $.trim($("#width_feet").val())
    i_width = $.trim($("#width_inches").val())
    bool = true
    focus = false
    if f_length.length < 1 and i_length.length < 1
      bool = false
      $("#err_length").html "Please enter length."
      focus = "length_feet"
    if f_width.length < 1 and i_width < 1
      bool = false
      $("#err_width").html "Please enter width."
      focus = "width_feet"  unless focus
    if bool
      $("#design_space").submit()
    else
      $("#" + focus).focus()
      false

$ ->
  SpacePicturesUploader.init()
