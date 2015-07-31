module ClientsHelper

  def profile_rows
    ['username', 'password', 'first_name', 'last_name', 'address', 'phone_number', 'billing_information', 'billing_address']
  end

  def collocutor(user)
    [t('faq.menu.designer'), t('faq.menu.customer')].detect {|role| role != user.role}
  end

end
