class @IntakeFormSaver

  @bind: ->
    formSelector = 'form.intake-form'
    $(formSelector).on('change', 'input, textarea', (event)->
      $input = $(event.target)
      $form = $(event.target).parents(formSelector)
      IntakeFormSaver.save($form)
    )

  @save: ($form)->
    $.ajax(
      data: $form.serializeArray()
      url: '/contests/save_intake_form'
      type: 'PUT'
    )

$(->
  IntakeFormSaver.bind()
)
