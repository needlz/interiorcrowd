class ReviewPage

  @init: ->
    Packages.init()
    @bindContinueButton()
    @validator = new ValidationMessages()

  @bindContinueButton: ->
    $('.continue').click (e) =>
      e.preventDefault()
      @validate()
      if @validator.valid
        $('#account_creation').submit()
      else
        @validator.focusOnMessage()
        false

  @validate: ->
    @validator.reset()
    $('.text-error').text('')

    pname = $.trim($('#project_name').val())
    if pname.length < 1
      @validator.addMessage $('#err_prj_name'), I18n.name_error, $('.project-name')

    pbudget = Packages.selectedPackage()
    if pbudget.length < 1
      @validator.addMessage $('#err_plan'), I18n.plan_error, $('.packages-description')

$ ->
  ReviewPage.init()
