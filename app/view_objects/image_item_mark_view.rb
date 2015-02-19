class ImageItemMarkView

  def initialize(mark, checked_mark)
    @mark = mark
    @checked_mark = checked_mark
  end

  def css_class
    result = "mark#{ mark.capitalize }"
    result = result + ' active' if mark == checked_mark
    result
  end

  attr_reader :mark, :checked_mark

end
