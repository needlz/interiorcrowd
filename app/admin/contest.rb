ActiveAdmin.register Contest do

  controller do
    def scoped_collection
      super.where.not(status: Contest::INCOMPLETE_STATUSES).includes :client
    end
  end

  index do
    column :id
    column :project_name
    column :status
    column :client
    actions
  end

  filter :status, as: :check_boxes, collection: proc { Contest::STATUSES - Contest::INCOMPLETE_STATUSES }

  scope 'All', :all
  scope 'Active', :active
  scope 'Inactive', :inactive

  member_action :charge, method: :put do
    contest = Contest.find(params[:id])
    begin
      payment = Payment.new(contest)
      payment.perform
      if payment.client_payment.try(:payment_status) == 'completed'
        SubmitContest.new(contest).try_perform if contest.brief_pending?
        redirect_to({:action => :show}, notice: 'Charged!')
      else
        redirect_to({:action => :show}, notice: payment.client_payment.last_error)
      end
    rescue StandardError => e
      redirect_to({:action => :show}, notice: e.message)
    end
  end

  action_item :charge, only: :show do
    if contest.client_payment.blank?
      link_to('Charge', charge_admin_contest_path(contest), method: :put)
    end
  end

end
