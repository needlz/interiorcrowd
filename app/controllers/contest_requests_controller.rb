class ContestRequestsController < ApplicationController
  before_filter :check_designer

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
      if session[:lookbook]['lookbook_photo']['document_id'].present?
        document_ids = session[:lookbook]['lookbook_photo']['document_id'].split(',')
        document_titles = session[:lookbook]['lookbook_photo']['photo_title']
        document_ids.each_with_index do |doc, index|
          LookbookDetail.create({lookbook_id: lookbook_id,
                                 image_id: doc,
                                 doc_type: 1,
                                 description: document_titles[index]})
        end
      end
      if session[:lookbook]['lookbook_link']['links'].present?
        document_ids = session[:lookbook]['lookbook_link']['links']
        document_titles = session[:lookbook]['lookbook_link']['link_title']
        document_ids.each_with_index do |doc, index|
          if doc.present?
            LookbookDetail.create({lookbook_id: lookbook_id, url: doc, doc_type: 2, description: document_titles[index]})
          end
        end
      end
      session[:lookbook] = nil
      if params[:op] == 'lock'
        crequest = ContestRequest.new({designer_id: session[:designer_id], contest_id: params[:id]})
        crequest.save
        flash[:notice] = "Lookbook has been successfully created and you also responded successfully."
        redirect_to contests_path
      else
        flash[:notice] = "Lookbook has been successfully saved."
        redirect_to lookbook_designer_path(params[:id])
      end
    end
  end

end
