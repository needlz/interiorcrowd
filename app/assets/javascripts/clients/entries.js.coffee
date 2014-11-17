$('document').ready ->
  $('.winner-answer').popover({
    html: true
    placement: 'auto'
    title: I18n.winner_dialog.title
    content: """
      <div>#{ I18n.winner_dialog.text }</div>
      <button type="button" class="btn btn-default">#{ I18n.winner_dialog.no }</button>
      <button type="button" class="btn btn-primary">#{ I18n.winner_dialog.yes }</button>
    """

  })