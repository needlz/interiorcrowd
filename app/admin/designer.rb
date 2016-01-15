ActiveAdmin.register Designer do

  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column :email
    column :plain_password
    column :created_at
    column :paid_for_concept_boards
    column 'Concept boards submitted' do |designer|
      date_string = params[:q][:by_submission_date_in_any] if params[:q]
      date_sym = date_string if date_string
      date = Date.parse(ActiveAdminExtensions::Designer.months_for_years[date_sym]) if date_sym
      date_range = date..date.next_month if date
      designer.contest_requests.ever_published.where(({ submitted_at: date_range } if date_range)).map do |request|
        link_to('#' + request.contest.id.to_s, admin_detailed_contest_path(request.contest))
      end.join('<br />').html_safe
    end
    column 'Contests won' do |designer|
      date_string = params[:q][:by_win_date_in_any] if params[:q]
      date_sym = date_string if date_string
      date = Date.parse(ActiveAdminExtensions::Designer.months_for_years[date_sym]) if date_sym
      date_range = date..date.next_month if date
      winning_requests = designer.contest_requests.ever_published.where(answer: 'winner')
      winning_requests.where(({ won_at: date_range } if date_range)).map do |request|
        link_to('#' + request.contest.id.to_s, admin_detailed_contest_path(request.contest))
      end.join('<br />').html_safe
    end
    column 'Contests completed' do |designer|
      date_string = params[:q][:by_completion_date_in_any] if params[:q]
      date_sym = date_string if date_string
      date = Date.parse(ActiveAdminExtensions::Designer.months_for_years[date_sym]) if date_sym
      date_range = date..date.next_month if date
      condition_hash = { finished_at: date_range } if date_range
      designer.contest_requests.ever_published.
          where(answer: 'winner').
          where(status: 'finished').
          joins(:contest).
          where(({ contests: condition_hash } if condition_hash) ).map do |request|
        link_to('#' + request.contest.id.to_s, admin_detailed_contest_path(request.contest))
      end.join('<br />').html_safe
    end
    column :portfolio_path
    column :phone_number
    column :address
    column :city
    column :state
    column :active
    actions
  end

  show do
    attributes_table do
      row :first_name
      row :last_name
      row :email
      row :plain_password
      row :created_at
      row :paid_for_concept_boards
      row 'Concept boards submitted' do |designer|
        designer.contest_requests.ever_published.map do |request|
          link_to('#' + request.contest.id.to_s, admin_detailed_contest_path(request.contest))
        end.join('<br />').html_safe
      end
      row 'Contests won' do |designer|
        designer.contest_requests.ever_published.where(answer: 'winner').map do |request|
          link_to('#' + request.contest.id.to_s, admin_detailed_contest_path(request.contest))
        end.join('<br />').html_safe
      end
      row 'Contests completed' do |designer|
        designer.contest_requests.ever_published.where(answer: 'winner').where(status: 'finished').map do |request|
          link_to('#' + request.contest.id.to_s, admin_detailed_contest_path(request.contest))
        end.join('<br />').html_safe
      end
      row :portfolio_path
      row :phone_number
      row :address
      row :city
      row :state
      row :active
    end
  end

  filter :first_name
  filter :last_name
  filter :email
  filter :plain_password
  filter :created_at
  filter :by_submission_date_in_any,
         label: 'Sort By Submission Date',
         as: :select,
         collection: ActiveAdminExtensions::Designer.months_for_years.keys
         # multiple: true
  filter :by_win_date_in_any,
         label: 'Sort By Win Date',
         as: :select,
         collection: ActiveAdminExtensions::Designer.months_for_years.keys
         # multiple: true
  filter :by_completion_date_in_any,
         label: 'Sort By Completion Date',
         as: :select,
         collection: ActiveAdminExtensions::Designer.months_for_years.keys
         # multiple: true
  filter :paid_for_concept_boards
  filter :portfolio_path
  filter :phone_number
  filter :address
  filter :city
  filter :state
  filter :active

  extend ActiveAdminExtensions::User

  extend_user

end
