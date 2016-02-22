include ActiveAdminExtensions::ContestDetails

ActiveAdmin.register Contest, as: "Detailed Contest" do

  actions :all, :except => [:new, :destroy, :edit, :show]

  controller do
    attr_accessor :plain
  end

  columns = Proc.new do
    column 'Contest id' do |contest|
      if controller.plain
        contest.id
      else
        link_to contest.id, admin_detailed_contest_path(contest)
      end
    end
    column 'Contest' do |contest|
      contest_name(contest)
    end
    column 'Charged?' do |contest|
      contest.client_payment.present?
    end
    column 'Start Date' do |contest|
      contest.submission_started_at
    end
    column 'Submission Deadline Date' do |contest|
      contest.phase_end if contest.submission?
    end
    column 'Designers' do |contest|
      designers_list(contest.requests.ever_published) do |statement, submission_date|
        statement + formatted_date(', submitted at ', submission_date)
      end
    end
    column 'Designer Comments' do |contest|
      designers_list(contest.requests.has_designer_comments)
    end
    column 'Winner' do |contest|
      winner_info(contest)
    end
    column 'End Date' do |contest|
      end_date(contest)
    end
    column 'Promo Code Name' do |contest|
      promocode_details(contest, :promocode)
    end
    column 'Promo Code Message' do |contest|
      promocode_details(contest, :display_message)
    end
  end

  index do
    selectable_column
    controller.plain = false
    instance_exec(&columns)
  end

  show do
    attributes_table do
      row 'Contest id' do |contest|
        link_to contest.id, admin_contest_path(contest)
      end
      row 'Contest' do |contest|
        contest_name(contest)
      end
      row 'Charged?' do |contest|
        contest.client_payment.present?
      end
      row 'Start Date' do |contest|
        contest.submission_started_at
      end
      row 'Designers' do |contest|
        designers_list(contest.requests.ever_published) do |statement, submission_date|
          statement + formatted_date(', submitted at ', submission_date)
        end
      end
      row 'Designer Comments' do |contest|
        designers_list(contest.requests.has_designer_comments)
      end
      row 'Winner' do |contest|
        winner_info(contest)
      end
      row 'End Date' do |contest|
        end_date(contest)
      end
      row 'Promo Code Name' do |contest|
        promocode_details(contest, :promocode)
      end
      row 'Promo Code Message' do |contest|
        promocode_details(contest, :display_message)
      end
    end
  end

  member_action :show, method: :get

  csv do
    controller.plain = true
    instance_exec(&columns)
  end

  filter :status, as: :check_boxes, collection: proc { Contest::STATUSES }
  filter :finished_at_month_in_any, label: 'Month', as: :select, collection: ActiveAdminExtensions::ContestDetails.months_for_years.keys, multiple: true
end
