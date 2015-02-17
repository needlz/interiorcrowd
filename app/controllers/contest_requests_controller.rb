class ContestRequestsController < ApplicationController
  before_filter :check_designer, only: [:create, :save_lookbook]
  before_filter :check_client, only: [:answer]

  def create
    @crequest = ContestRequest.new(params[:contest_request])
    if @crequest.save
      flash[:notice] = "Respond created successfully"
      redirect_to contests_path
    else
      flash[:error] = @crequest.errors.full_messages
      render template: "contests/respond"
    end
  end

  def save_lookbook
    lookbook = Lookbook.find_by_designer_id_and_contest_id(session[:designer_id], params[:id])

    if lookbook.blank?
      lookbook = Lookbook.new({designer_id: session[:designer_id],
                               contest_id: params[:id],
                               feedback: session[:lookbook]['feedback']})
      if lookbook.save()
        lookbook_id = lookbook.id
      else
        redirect_to preview_lookbook_designer_path(params[:id])
        flash[:error] = lookbook.errors.full_messages
      end
    else
      lookbook_id = lookbook.id
      lookbook.update_attributes({feedback: session[:lookbook]['feedback']})
    end

    if lookbook_id.present?
      LookbookDetail.destroy_all(lookbook_id: lookbook_id)
      if session[:lookbook].try(:[], 'picture').try(:[], 'ids').present?
        document_ids = session[:lookbook]['picture']['ids']
        document_titles = session[:lookbook]['picture']['titles']
        document_ids.each_with_index do |doc, index|
          LookbookDetail.create({lookbook_id: lookbook_id,
                                 image_id: doc,
                                 doc_type: 1,
                                 description: document_titles[index]})
        end
      end
      if session[:lookbook].try(:[], 'link').try(:[], 'urls').present?
        document_urls = session[:lookbook]['link']['urls']
        document_titles = session[:lookbook]['link']['titles']
        document_urls.each_with_index do |url, index|
          if url.present?
            LookbookDetail.create({ lookbook_id: lookbook_id,
                                    url: url,
                                    doc_type: 2,
                                    description: document_titles[index] })
          end
        end
      end
      session[:lookbook] = nil
      if params[:op] == 'lock'
        request = ContestRequest.new({designer_id: session[:designer_id],
                                       contest_id: params[:id],
                                       lookbook_id: lookbook_id})
        request.save
        flash[:notice] = "Lookbook has been successfully created and you also responded successfully."
        redirect_to contests_path
      else
        flash[:notice] = "Lookbook has been successfully saved."
        redirect_to lookbook_designer_path(params[:id])
      end
    end
  end

  def add_comment
    comment = ConceptBoardComment.create(params['comment'].merge({user_id: current_user.id, role: current_user.role }))
    render json: { comment: comment, user_name: current_user.name }
  end

  def answer
    request = ContestRequest.find(params[:id])
    replied = request.reply(params[:answer], session[:client_id])
    render json: { answered: replied }
  end

  def approve_fulfillment
    request = ContestRequest.find(params[:id])
    approved = request.approve_fulfillment!
    render json: { approved: approved }
  end

  def show
    return unless check_client
    @client = Client.find(session[:client_id])
    @request = ContestRequest.find(params[:id])
    @show_answer_options = @request.answerable?
    @navigation = Navigation::ClientCenter.new(:entries)
  end
end
