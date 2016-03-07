include ActiveAdminExtensions::ContestDetails

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
      scope = designer.contest_requests.ever_published
      get_param = params[:q][:by_submission_date_in_any]
      field_to_search = 'contest_requests.submitted_at'

      requests_to_display = requests_find_by(scope, get_param, field_to_search)

      requests_to_display.map do |request|
        link_to('#' + request.contest.id.to_s, admin_detailed_contest_path(request.contest))
      end.join('<br />').html_safe

    end if params[:q] && params[:q][:by_submission_date_in_any]
    column 'Contests won' do |designer|
      scope = designer.contest_requests.ever_published
      get_param = params[:q][:by_win_date_in_any]
      field_to_search = 'contest_requests.won_at'

      requests_to_display = requests_find_by(scope, get_param, field_to_search)

      requests_to_display.map do |request|
        link_to('#' + request.contest.id.to_s, admin_detailed_contest_path(request.contest))
      end.join('<br />').html_safe

    end if params[:q] && params[:q][:by_win_date_in_any]
    column 'Contests completed' do |designer|
      scope = designer.contest_requests.ever_published.where(answer: 'winner').where(status: 'finished').joins(:contest)
      get_param = params[:q][:by_completion_date_in_any]
      field_to_search = 'contests.finished_at'

      requests_to_display = requests_find_by(scope, get_param, field_to_search)

      requests_to_display.map do |request|
        link_to('#' + request.contest.id.to_s, admin_detailed_contest_path(request.contest))
      end.join('<br />').html_safe

    end if params[:q] && params[:q][:by_completion_date_in_any]
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
         label: 'Submission Date',
         as: :select,
         collection: ActiveAdminExtensions::ContestDetails.months_for_years.keys,
         multiple: true
  filter :by_win_date_in_any,
         label: 'Win Date',
         as: :select,
         collection: ActiveAdminExtensions::ContestDetails.months_for_years.keys,
         multiple: true
  filter :by_completion_date_in_any,
         label: 'Completion Date',
         as: :select,
         collection: ActiveAdminExtensions::ContestDetails.months_for_years.keys,
         multiple: true
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
