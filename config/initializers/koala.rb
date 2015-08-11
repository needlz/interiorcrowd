Koala::Facebook::OAuth.class_eval do
  def initialize_with_default_settings(*args)
    case args.size
      when 0, 1
        raise "application id and/or secret are not specified in the config" unless Settings.facebook.app_id && Settings.facebook.secret
        initialize_without_default_settings(Settings.facebook.app_id, Settings.facebook.secret, args.first)
      when 2, 3
        initialize_without_default_settings(*args)
    end
  end

  alias_method_chain :initialize, :default_settings
end
