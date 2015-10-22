include ActiveAdminExtensions::ContestDetails

ActiveAdmin.register Contest, as: "Detailed Contest" do
  actions :all, :except => [:new, :destroy, :edit, :show]

  index do
    selectable_column
    column 'Contest id' do |contest|
      link_to contest.id, admin_contest_path(contest)
    end
    column 'Contest' do |contest|
      contest_name(contest)
    end
    column 'Start Date' do |contest|
      contest.submission_started_at
    end
    column 'Designers' do |contest|
      designers_list(contest)
    end
    column 'Winner' do |contest|
      winner_info(contest)
    end
    column 'End Date' do |contest|
      end_date(contest)
    end
  end

  filter :id, label: 'Contest ID'
  filter :client
  filter :project_name
  filter :submission_started_at, label: 'Start Date'
  filter :finished_at, label: 'End Date'
end
