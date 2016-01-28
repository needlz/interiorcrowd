require "will_paginate/array"

ActiveAdmin.register_page 'Email templates' do

  collection = UserMailer::MANDRILL_TEMPLATES.map { |k, mandrill_template| Hashie::Mash.new(mandrill_template) }

  content do
    table_for collection do
      column 'Mandrill template', :template do |item|
        link_to(item.template, "https://mandrillapp.com/templates/code?id=#{ item.template }")
      end
      column 'Recipient', :recipient do |item|
        item.description.recipients
      end
      column 'When', :occurrence do |item|
        item.description.occurrence
      end
    end
  end

end
