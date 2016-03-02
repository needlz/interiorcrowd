class @IntakeFormSaver

  @bind: ->
    formSelector = 'form.intake-form'
    $(formSelector).on('change', 'input, textarea', (event)->
      $input = $(event.target)
      $form = $(event.target).parents(formSelector)
      IntakeFormSaver.save($form)
    )

  @save: ($form)->
    array = $form.serializeArray()
    contestId = $('.contest[data-id]').attr('data-id')
    array.push({ name: 'id', value: contestId }) if contestId
    $.ajax(
      data: array
      url: '/contests/save_intake_form'
      type: 'PUT'
    )

$(->
  IntakeFormSaver.bind()
)
