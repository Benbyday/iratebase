require 'iratebase'

module Iratebase
  class HateQuery
    class QueryError < RuntimeError
    end

    class KeyError < QueryError
    end

    class FilterError < QueryError
    end

    @@flags = {
      :about_ethnicity => 1,
      :about_nationality => 2,
      :about_religion => 4,
      :about_gender => 8,
      :about_sexual_orientation => 16,
      :about_disability => 32,
      :about_class => 64,
      :archaic => 128,
      :all => 255
    }

    def initialize(key = '')
      self.key = key
      @version = 3
      @subversion = 0
      @query_type = nil
      @output = :json
      @vocabulary = nil
      @variant_of = nil
      @language = 'eng'
      @flag_values = 0
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

    def set_version(ver = 3, subver = 0)
      self.version = ver
      self.subversion = subver
      self
    end

    def key=(key)
      @key = if key == '' || HateQuery.valid_key(key)
               key
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

    def vocabulary=(vocab)
      @vocabulary = if HateQuery.valid_vocabulary(vocab)
                      vocab
                    else
                      raise FilterError.exception 'invalid vocabulary'
                      nil
                    end
    end

    def set_vocabulary(vocab)
      self.vocabulary = vocab
      self
    end

    def variant_of=(var)
      @variant_of = if HateQuery.valid_vocabulary(var)
                      var
                    else
                      raise FilterError.exception 'invalid variant'
                      nil
                    end
    end

    def set_variant_of(var)
      self.variant_of = var
      self
    end

    def language=(lang)
      @language = if HateQuery.valid_language(lang)
                    lang
                  else
                    raise FilterError.exception 'invalid language'
                    nil
                  end
    end

    def set_language(lang)
      self.language = lang
      self
    end

    def is(*flags)
      i = 0
      flags.each do |flag|
        i += @@flags[flag.to_s.downcase.to_sym]
      end
      @flag_values |= i
      @relevant_flags |= i
      self
    end

    def is_not(*flags)
      i = 0
      flags.each do |flag|
        i += @@flags[flag.to_s.downcase.to_sym]
      end
      @relevant_flags |= i
      @flag_values &= @@flags[:all] & ~i
      self
    end

    def forget(*flags)
      i = 0
      flags.each do |flag|
        i += @@flags[flag.to_s.downcase.to_sym]
      end
      @relevant_flags &= @@flags[:all] & ~i
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

    def vocabulary
      @vocabulary.to_s
    end

    def variant_of
      @variant_of.to_s
    end

    def language
      @language.to_s
    end

    def flags_string
      if @relevant_flags <= 0
        return ""
      end
      is = []
      is_not = []
      (Math.log2(@relevant_flags).floor + 1).times do |f|
        flag = 2**f
        if @relevant_flags & flag == flag
          flag_word = @@flags.key(flag).to_s
          if @flag_values & flag == flag
            is << flag_word
          else
            is_not << flag_word
          end
        end
      end
      return "is " + is.inspect + " is not " + is_not.inspect
    end
  end
end
