class CreateRealtorContact

  attr_reader :realtor_contact, :saved

  def initialize(contact_attributes)
    @contact_attributes = contact_attributes
  end

  def perform
    @saved = false
    ActiveRecord::Base.transaction do
      @realtor_contact = RealtorContact.new(contact_attributes)
      @saved = @realtor_contact.save
      notify_owner if saved
    end
  end

  private

  attr_reader :contact_attributes

  def notify_owner
    Jobs::Mailer.schedule(:realtor_signup, [realtor_contact.id])
  end

end
