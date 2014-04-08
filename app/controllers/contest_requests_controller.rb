class ContestRequestsController < ApplicationController
   before_filter :check_designer
   
   def create
     
     @crequest = ContestRequest.new(params[:contest_request])
     
     if @crequest.save
       flash[:notice] = "Respond created successfully"
       redirect_to contests_path  
     else
       flash[:error] = @crequest.errors.full_messages
       render :template => "contests/respond"
     end
   end
  
end
