class AddMissingTimestamps < ActiveRecord::Migration
  def change
    add_timestamps :example_links
    execute "UPDATE example_links SET created_at='#{ Time.now }', updated_at='#{ Time.now }'"
    add_timestamps :portfolio_awards
    execute "UPDATE portfolio_awards SET created_at='#{ Time.now }', updated_at='#{ Time.now }'"
    add_timestamps :designer_invitations
    execute "UPDATE designer_invitations SET created_at='#{ Time.now }', updated_at='#{ Time.now }'"
    add_timestamps :reviewer_invitations
    execute "UPDATE reviewer_invitations SET created_at='#{ Time.now }', updated_at='#{ Time.now }'"
    add_timestamps :reviewer_feedbacks
    execute "UPDATE reviewer_feedbacks SET created_at='#{ Time.now }', updated_at='#{ Time.now }'"
  end
end
