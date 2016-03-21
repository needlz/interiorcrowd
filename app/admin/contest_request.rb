ActiveAdmin.register ContestRequest do

  index do
    id_column
    column :feedback
    column :status do |request|
      "#{ request.status.to_s } (#{ ContestResponseView.status_name(request.status) })"
    end
    column :answer
    column :final_note
    column :pull_together_note
    column :token
    column :created_at
    column :updated_at
    actions
  end

  member_action :revert, method: :post do
    contest_request = ContestRequest.find(params[:id])
    RevertState::ContestRequest.new(contest_request).send("to_#{ params[:to_state] }")
    redirect_to admin_contest_request_path(contest_request.id)
  end

  RevertState::ContestRequest::STATES_FLOW.each do |previous_state|
    action_item 'Revert to ' + previous_state,
                only: [:show],
                if: ->{ RevertState::ContestRequest.available_reverts(resource).include?(previous_state) } do
      revert_message = RevertState::ContestRequest.revert_message(previous_state)
      link_to('Revert to ' + previous_state, revert_admin_contest_request_path(resource.id, to_state: previous_state),
              data: { confirm: "Are you sure you want to move #{ revert_message }?" },
              method: :post)
    end
  end

end
