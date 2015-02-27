module PackagesHelper

  def package_css_class(index, count)
    middle_range = (2..count-1)
    'middle-package' if middle_range.include?(index + 1)
  end

end
