class RealtorContactsController < ApplicationController

  def sfar
    render
  end

  def create
    create_contact = CreateRealtorContact.new(realtor_contact_params)
    create_contact.perform
    result =
      if create_contact.saved
        { notice: 'Contact saved!' }
      else
        { alert: create_contact.realtor_contact.errors.full_messages.join(', ') }
      end
    respond_to do |format|
      format.html do
        result.each { |key, value| flash[key] = value }
        redirect_to sfar_path(anchor: 'sfarSubmitButton')
      end

      format.json do
        render json: result
      end
    end
  end

  private

  def realtor_contact_params
    contact_params = params.require(:realtor_contact)
    phone_string = contact_params[:phone].join
    contact_params.merge!(phone: phone_string)
    contact_params.permit(:first_name, :last_name, :email, :brokerage, :choice, :phone)
  end

end
