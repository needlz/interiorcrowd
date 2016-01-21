class FindUserEmailsWithNameLike
  def initialize(name_part)
    @name_part = name_part
  end

  def perform
    emails = Designer.where("first_name ILIKE '%#{@name_part}%' OR last_name ILIKE '%#{@name_part}%'").map(&:email)
    emails += Client.where("first_name ILIKE '%#{@name_part}%' OR last_name ILIKE '%#{@name_part}%'").map(&:email)
    emails
  end
end
