require 'iratebase'

module Iratebase
  class HateQuery
    class QueryError < RuntimeError
    end

    class KeyError < QueryError
    end

    ABOUT_ETHNICITY = 1
    ABOUT_NATIONALITY = 2
    ABOUT_RELIGION = 4
    ABOUT_GENDER = 8
    ABOUT_SEXUAL_ORIENTATION = 16
    ABOUT_DISABILITY = 32
    ABOUT_CLASS = 64
    ARCHAIC = 128

    def initialize(key = '')
      self.key = key
      @version = 3
      @subversion = 0
      @query_type = nil
      @output = :json
      @vocabulary = nil
      @variant_of = nil
      @language = 'eng'
      @flags = 0
      @relevant_flags = 0
      @country = 'US'
      @city = nil
      @type = nil
      @start_date = nil
      @end_date = nil
    end

    # Class methods
    def self.valid_key(key)
      Iratebase.perfect_match(/[0-9a-f]{32}/, key)
    end

    def self.valid_vocabulary(vocab)
      Iratebase.perfect_match(/[a-zA-Z \-]+/, vocab)
    end

    def self.valid_language(lang)
      Iratebase.perfect_match(/[a-z]{3}/, lang)
    end

    def self.valid_country(country)
      Iratebase.perfect_match(/[A-Z]{2}/, country)
    end

    def self.valid_sighting_type(type)
      Iratebase.perfect_match(/[rout]/, type)
    end

    def self.valid_date(date)
      Iratebase.perfect_match(/\d{4}-\d{2}-\d{2}/, date)
    end

    # Setters
    def version=(ver)
      if ver.is_a? Integer
        @version = ver
      else
        false
      end
    end

    def subversion=(subv)
      if subv.is_a? Integer
        @subversion = subv
      else
        false
      end
    end

    def key=(key)
      @key = if key == '' || HateQuery.valid_key(key)
               key.to_s
             else
               raise KeyError.exception 'a key must be a 32 digit hexadecimal '\
                  'number. You can obtain a key from '\
                  'https://www.hatebase.org/login_register/redirect/request_api'
               ''
             end
    end

    def set_key(key)
      self.key = key
      self
    end

    def vocab
      @query_type = :vocabulary
      self
    end

    def sightings
      @query_type = :sightings
      self
    end

    def json
      @output = :json
      self
    end

    def xml
      @output = :xml
      self
    end

    # Getters
    def version
      'v' + @version.to_s + '-' + @subversion.to_s
    end

    def key
      String.new(@key)
    end

    def query_type
      @query_type.to_s
    end

    def output
      @output.to_s
    end
  end
end
