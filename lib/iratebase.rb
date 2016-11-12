require "iratebase/version"
require "iratebase/hate_query"

module Iratebase
  def self.perfect_match(regexp, str)
    m = regexp.match(str)
    if m == nil
      return false
    else
      return m.to_s == str
    end
  end
end
