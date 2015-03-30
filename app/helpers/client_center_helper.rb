module ClientCenterHelper

  def responses_filter_options
    { '' => t('client_center.entries.responses_filter_all') ,
      'favorite' => t('client_center.entries.answers.favorite'),
      'maybe' => t('client_center.entries.answers.maybe') ,
      'no' => t('client_center.entries.answers.no'),
      'winner' => t('client_center.entries.answers.winner') }
  end

  def show_time_button?
    false
  end

end
