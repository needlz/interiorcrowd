class FulfillmentApprovedEdit

  @init: ->
    @bindFooterButtons()

  @form: ->
    $('.edit_contest_request')

  @bindFooterButtons: ->
    $form = @form()
    $('.footer .save-button').click (e)->
      e.preventDefault()
      $form.submit()

    $('.footer .submit-button').click (e)->
      e.preventDefault()
      $status_input = $('<input type="hidden">').attr('name', 'contest_request[status]').val('finished')
      $status_input.appendTo($form)
      $form.submit()

$ ->
  FulfillmentApprovedEdit.bindFooterButtons()
