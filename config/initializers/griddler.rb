Griddler.configure do |config|
  config.reply_delimiter = '// Add your reply above'
end

module Griddler::EmailParser

  def self.regex_split_points
    [
        reply_delimeter_regex,
        Regexp.new("^[\\d\\-: ]+.+InteriorCrowd <notification@interiorcrowd.com>:$"),
        /^[[:space:]]*[-]+[[:space:]]*Original Message[[:space:]]*[-]+[[:space:]]*$/i,
        /^[[:space:]]*--[[:space:]]*$/,
        /^[[:space:]]*\>?[[:space:]]*On.*\r?\n?.*wrote:\r?\n?$/,
        /On.*wrote:/,
        /\*?From:.*$/i,
        /^[[:space:]]*\d{4}\/\d{1,2}\/\d{1,2}[[:space:]].*[[:space:]]<.*>?$/i
    ]
  end

end
