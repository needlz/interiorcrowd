require 'mandrill'

module MandrillMailer
  extend ActiveSupport::Concern
  @attachments = []

  def template(name)
    @template_name = name
  end

  def merge_vars(vars)
    @merge_vars = vars
  end

  included do

    def mail(options = {})
      if Rails.env.development?
        send_to_local_server(options)
      else
        send_to_mandrill(options)
      end
    end

  end

  def global_merge_vars
    return unless @merge_vars
    @merge_vars.inject([]) do |arr, (key, val)|
      arr.push({ 'name' => key.upcase, 'content' => val });
      arr
    end
  end

  def api
    @api ||= Mandrill::API.new(Settings.mandrill.api_token)
  end

  def set_template_values(template_params)
    @merge_vars = template_params
  end

  def send_to_local_server(options)
    mandrill_rendered = api.templates.render(@template_name, [], global_merge_vars)['html']
    options[:to] = options[:to].map { |to_hash| to_hash[:email] }
    options[:from] = 'development'
    super(options) do |format|
      format.html { render text: mandrill_rendered.html_safe }
      format.text { render text: mandrill_rendered.html_safe }
    end
  end

  def send_to_mandrill(options)
    recipients = options[:to]

    raise ArgumentError.new('no recipients') if recipients.map { |recipient| recipient[:email] }.any?(&:blank?)
    message = {
      to: recipients,
      global_merge_vars: global_merge_vars,
      metadata: {
        email_id: options[:email_id],
        environment: Rails.env
      }
    }
    message.merge!(subject: options[:subject]) if options[:subject]
    api_response = api.messages.send_template(@template_name, [], message)
    if options[:email_id]
      email = OutboundEmail.find(options[:email_id])
      email.update_attributes!(api_response: api_response)
    end
    Rails.logger.info(api_response)
  end
end
