module ClientsHelper

  def profile_rows
    %w[username password first_name last_name address phone_number]
  end

  def collocutor(user)
    [t('faq.menu.designer'), t('faq.menu.customer')].detect {|role| role != user.role}
  end

end
