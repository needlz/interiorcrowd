class ReviewPage

  @continuButtonSelector: '.continueBtn'

  @init: ->
    Packages.init()
    @bindContinueButton()
    @validator = new ValidationMessages()

    mixpanel.track_forms '#account_creation', 'Contest creation - Preview', (form)->
      $form = $(form)
      { data: $form.serializeArray() }

  @bindContinueButton: ->
    $(@continuButtonSelector).click (e) =>
      e.preventDefault()
      @validate()
      if @validator.valid
        $('#account_creation [type=submit]').click()
      else
        @validator.focusOnMessage()
        false

  @validate: ->
    @validator.reset()
    $('.text-error').text('')

    contest_name = $.trim($('#project_name').val())
    if contest_name.length < 1
      @validator.addMessage $('#err_prj_name'), I18n.name_error, $('.project-name')

    package_id = Packages.selectedPackage()
    if package_id.length < 1
      @validator.addMessage $('#err_plan'), I18n.plan_error, $('.packages-description')

$ ->
  ReviewPage.init()
