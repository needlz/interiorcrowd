ActiveAdmin.register InboundEmail do

  index do
    column 'id' do |email|
      link_to(email.id, admin_inbound_email_path(email.id))
    end
    column 'json content' do |email|
      JSON.pretty_generate(JSON.parse(email.json_content)).gsub(/\n/, '<br>')
    end
    column 'processed?' do |email|
      email.processed
    end
    column 'created_at' do |email|
      email.created_at
    end
  end

end
