class AddEmailToNewsletter < Action

  def initialize(user)
    @user = user
  end

  def perform
    fail('Mailchimp data not provided') if api_key.blank? || list_id.blank?
    member_params =  { email_address: user.email, status: 'subscribed' }
    merge_fields = {}
    merge_fields.merge!(FNAME: user.first_name) if user.first_name.present?
    merge_fields.merge!(LNAME: user.last_name) if user.last_name.present?
    member_params.merge!(merge_fields: merge_fields) if merge_fields.present?
    gibbon = Gibbon::Request.new(api_key: api_key)
    gibbon.lists(list_id).members.create(body: member_params)
  end

  private

  attr_reader :user

  def list_id
    Settings.mailchimp.list_id
  end

  def api_key
    Settings.mailchimp.api_key
  end

end
