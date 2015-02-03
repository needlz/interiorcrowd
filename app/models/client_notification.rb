class ClientNotification < UserNotification

  belongs_to :client, foreign_key: :user_id

end
