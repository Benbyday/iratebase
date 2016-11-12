require "iratebase/version"
require "iratebase/hate_query"

module Iratebase
  def self.perfect_match(regexp, str)
    regexp.match(str).to_s == str
  end
end
