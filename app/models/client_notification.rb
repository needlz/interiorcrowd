class ClientNotification < UserNotification

  self.inheritance_column = :type

  belongs_to :client, foreign_key: :user_id

end
