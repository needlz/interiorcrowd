require 'mandrill'

module MandrillMailer
  @attachments = []

  def template(name)
    @template_name = name
  end

  def merge_vars(vars)
    @merge_vars = vars
  end

  def mail(options = {})
    recipients = options[:to]

    return if recipients.map { |recipient| recipient[:email] }.any?(&:blank?)
    message = {
        to: recipients,
        global_merge_vars: global_merge_vars
    }
    message.merge!(subject: options[:subject]) if options[:subject]

    api.messages.send_template(@template_name, [], message)
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
end
