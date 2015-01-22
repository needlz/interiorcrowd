class UniquePathGenerator

  def self.generate(preferred_path, existing_paths)
    suggested_path = preferred_path.dup
    i = 1
    until !existing_paths.find { |path| path == suggested_path }
      suggested_path = add_hash_to_path(preferred_path, i)
      i += 1
    end
    suggested_path
  end

  def self.add_hash_to_path(path, hash)
    "#{ path }_#{ hash }"
  end

end
