module Possessive

  APOSTROPHE_CHAR = '’'

end

class String

  def possessive
    return self if self.empty?
    self + ('s' == self[-1,1] ? Possessive::APOSTROPHE_CHAR : Possessive::APOSTROPHE_CHAR + 's')
  end

end
