class Policy

  attr_reader :error

  def initialize(user)
    @permissions = []
  end

  def require!
    raise error unless can?
  end

  def can?
    init
    result = permissions.all?
    create_error unless result
    result
  end

  private

  attr_reader :user, :permissions

  def any_not_permitted?
    permissions.any? { |permitted| !permitted }
  end

  def create_error
    @error = PolicyError.new
  end

  def init
    @error = nil
    raise('No policy provided') if permissions.blank?
  end

end
