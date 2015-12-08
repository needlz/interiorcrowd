class DesignerInitialization

  def initialize(creation_options)
    @plain_password = creation_options[:plain_password]
    @portfolio_params = creation_options[:portfolio_params]
    @designer = creation_options[:designer]
  end

  def perform
    create_portfolio
    create_welcome_notification
    send_mails
  end

  private

  attr_reader :plain_password, :designer, :portfolio_params

  def create_portfolio
    designer.create_portfolio(portfolio_params)
  end

  def create_welcome_notification
    designer.user_notifications.create(type: 'DesignerWelcomeNotification')
  end

  def send_mails
    Jobs::Mailer.schedule(:designer_registered, [designer])
    Jobs::Mailer.schedule(:user_registration_info, [designer.role, designer.id])
  end

end
