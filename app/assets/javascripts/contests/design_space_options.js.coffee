class @DesignSpaceOptions
  @maxValueForInches = 11.99
  @inchesInputs: '.in-inches'
  @numericInputs: '.in-inches, .in-feet'
  @feedbackTextareaSelector: 'textarea[name="design_space[feedback]"]'

  @init: (options = {})->
    @feedbackPlaceholder = options.feedbackPlaceholder
    @setupFeedbackPlaceholder()
    @initFeedbackPopup()

    @bindInchesInputs()
    @mobileInputsPlaceholder()

  @bindInchesInputs: ->
    $(@inchesInputs).NumberLimiter(@maxValueForInches)
    $(@numericInputs).ForceNumericOnly()

  @setupFeedbackPlaceholder: ->
    $textarea = $(@feedbackTextareaSelector)
    placeholder = @feedbackPlaceholder

    $textarea.emulatePlaceholder(placeholder)

  @initFeedbackPopup: ->
    $('.feedback [data-toggle="popover"]').popover(viewport: '.feedback', container: '.feedback')

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

  @validateLocationZip: ->
    @zipSelector = '#design_space_zip'
    @validator = new ValidationMessages()

    $('.text-error').text('')
    @validator.reset()

    zip = $.trim($(@zipSelector).val())
    zip_regex = /^\d{5}(-\d{4})?$/
    unless zip.match zip_regex
      @validator.addMessage $("#err_zip"), Location.wrong_value_error, $('.location-zip')
    unless zip.length
      @validator.addMessage $("#err_zip"), Location.empty_value_error, $('.location-zip')

    @validator.valid
    