class PaperclipForSound < ActiveRecord::Migration

  def self.up
    add_attachment :sounds, :audio
  end

  def self.down
    remove_attachment :sounds, :audio
  end

end
