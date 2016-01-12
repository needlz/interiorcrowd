ActiveAdmin.register_page 'Designer activity' do
  menu priority: 12

  content do
    form_for 'activity_query', url: admin_designer_activity_download_csv_path, method: :get do |f|
      f.date_select :month, discard_day: true
      f.submit 'Download CSV'
    end
  end

  controller do
    def get_contest_ids(concept_boards)
      concept_boards.map { |concept_board| '#' + concept_board.contest.id.to_s }.join(', ')
    end
  end

  page_action :download_csv, method: :get do
    month = Date.new params[:activity_query]['month(1i)'].to_i,
                     params[:activity_query]['month(2i)'].to_i,
                     params[:activity_query]['month(3i)'].to_i

    csv = CSV.generate do |csv|
      csv << ['Designer Name', 'Number of concept boards submitted', 'No of contests won', 'Contests completed']
      Designer.active.each do |designer|
        name = designer.name


        submitted_requests = designer.contest_requests.where('submitted_at >= ? AND submitted_at < ?',
                                                             month.beginning_of_month, month.end_of_month).uniq
        submitted_length = submitted_requests.length
        submitted_count = submitted_length.to_s
        submitted_count = submitted_count + " (#{ get_contest_ids(submitted_requests) })" if submitted_length > 0

        won_requests = designer.contest_requests.where('won_at >= ? AND won_at < ?',
            month.beginning_of_month, month.end_of_month).uniq
        won_length = won_requests.length
        won_count = won_length.to_s
        won_count = won_count + " (#{ get_contest_ids(won_requests) })" if won_length > 0

        completed_requests = designer.contest_requests.finished.joins(:contest).
            where('contests.finished_at >= ? AND contests.finished_at < ?',
                  month.beginning_of_month, month.end_of_month).uniq
        completed_length = completed_requests.length
        completed_count = completed_length.to_s
        completed_count = completed_count + " (#{ get_contest_ids(completed_requests) })" if completed_length > 0

        csv << [name, submitted_count, won_count, completed_count]
      end
    end

    send_data csv, filename: "designer_activity_#{ month.strftime('%b_%Y') }.csv"
  end
end