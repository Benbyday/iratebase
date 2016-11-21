require 'uri'
require 'net/http'
require 'openssl'
require 'json'
require 'find'
require 'iratebase/version'
require 'iratebase/valid'
require 'iratebase/errors'
require 'iratebase/hatebase'
require 'iratebase/hate_query'

module Iratebase
  def Iratebase.find_key(path)
    key = ""
    Find.find(path) do |path|
      if path =~ /.*hatebase_key\.txt/
        File.open(path) do |f|
          f.each_line do |line|
            key += line
          end
        end
        key.strip!
      end
    end
    key
  end
end
