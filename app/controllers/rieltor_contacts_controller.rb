class RieltorContactsController < ApplicationController

  def sfar
    render
  end

  def create
    new_rieltor = RieltorContact.new(retailer_contact_params)
    result =
      if new_rieltor.save
        { notice: 'Contact saved!' }
      else
        { alert: new_rieltor.errors.full_messages.join(', ') }
      end
    respond_to do |format|
      format.html do
        result.each { |key, value| flash[key] = value }
        p flash[:alert]
        redirect_to sfar_path
      end

      format.json do
        render json: result
      end
    end
  end

  private

  def retailer_contact_params
    params.require(:rieltor_contact).permit(:first_name, :last_name, :email, :brokerage, :choice, :phone)
  end

end
