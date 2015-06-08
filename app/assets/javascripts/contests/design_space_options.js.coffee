class @DesignSpaceOptions
  @maxValueForInches = 11.99
  @inchesInputs: '.in-inches'
  @numericInputs: '.in-inches, .in-feet'
  @feedbackTextareaSelector: 'textarea[name="design_space[feedback]"]'

  @init: (options)->
    @feedbackPlaceholder = options.feedbackPlaceholder
    @setupFeedbackPlaceholder()

    @bindInchesInputs()

  @bindInchesInputs: ->
    $(@inchesInputs).NumberLimiter(@maxValueForInches)
    $(@numericInputs).ForceNumericOnly()

  @setupFeedbackPlaceholder: ->
    $textarea = $(@feedbackTextareaSelector)

    placeholder = @feedbackPlaceholder
    $textarea.val(placeholder)
    $textarea.focus ->
      if $(this).val() == placeholder
        $(this).val ''
    $textarea.blur ->
      if $(this).val() == ''
        $(this).val placeholder
