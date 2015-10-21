class DowncaseUserEmails < ActiveRecord::Migration
  def change
    [Designer, Client].each do |user_class|
      user_class.update_all('email = lower(email)')
    end
  end
end
