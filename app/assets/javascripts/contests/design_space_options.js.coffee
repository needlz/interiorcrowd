class @DesignSpaceOptions
  @maxValueForInches = 11.99
  @inchesInputs: '.in-inches'
  @numericInputs: '.in-inches, .in-feet'
  @feedbackTextareaSelector: 'textarea[name="design_space[feedback]"]'

  @init: (options = {})->
    @feedbackPlaceholder = options.feedbackPlaceholder
    @setupFeedbackPlaceholder()

    @bindInchesInputs()
    @mobileInputsPlaceholder()

  @bindInchesInputs: ->
    $(@inchesInputs).NumberLimiter(@maxValueForInches)
    $(@numericInputs).ForceNumericOnly()

  @setupFeedbackPlaceholder: ->
    $textarea = $(@feedbackTextareaSelector)
    placeholder = @feedbackPlaceholder
    $textarea.emulatePlaceholder(placeholder)

  @mobileInputsPlaceholder: ->
    @toggleMobileInputsPlaceholder()
    $(window).resize =>
      @toggleMobileInputsPlaceholder()

  @toggleMobileInputsPlaceholder: ->
    showPlaceholder = window.matchMedia('(max-width: 320px)').matches
    $('.roomDimension input').each (index, input)->
      $input = $(input)
      if showPlaceholder
        $input.attr('placeholder', $input.data('placeholder'))
      else
        $input.attr('placeholder', '')

  @clearFeedback: ->
    $feedbackTextarea = $(@feedbackTextareaSelector)
    if $feedbackTextarea.val() == @feedbackPlaceholder
      $feedbackTextarea.val ''