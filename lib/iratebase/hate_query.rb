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

    @@filters = {
      :vocabulary => :vocabulary,
      :variant_of => :vocabulary,
      :language => :language,
      :country => :country,
      :city => :vocabulary,
      :sighting_type => :sighting_type,
      :start_date => :date,
      :end_date => :date
    }

    @@valids = {
      :key => /[0-9a-f]{32}/,
      :vocabulary => /[a-zA-Z \-]+/,
      :language => /[a-z]{3}/,
      :country => /[A-Z]{2}/,
      :sighting_type => /[rout]/,
      :date => /\d{4}-\d{2}-\d{2}/
    }

    @@valid = Iratebase::Valid.new

    @@valids.each do |key, val|
      @@valid.from_regex(key, val)
    end

    @@filters.each do |filter, valid|
      basic_set = (filter.to_s + '=').to_sym
      bs = Proc.new do |set|
        value = if @@valid.method(valid).call(set)
                  "#{set}"
                else
                  raise FilterError.exception "invalid #{filter}"
                  nil
                end
        instance_variable_set("@#{filter}", value)
      end
      define_method(basic_set, bs)
      swift_set = ("set_" + filter.to_s).to_sym
      ss = Proc.new do |set|
        self.method(basic_set).call(set)
        self
      end
      define_method(swift_set, ss)
    end

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
      @sighting_type = nil
      @start_date = nil
      @end_date = nil
    end

    # TODO: Get rid of all of these valid methods.
    # Class methods
    def self.valid_key(key)
      @@valid.key(key)
    end

    def self.valid_vocabulary(vocab)
      @@valid.vocabulary(vocab)
    end

    def self.valid_language(lang)
      @@valid.language(lang)
    end

    def self.valid_country(country)
      @@valid.country(country)
    end

    def self.valid_sighting_type(type)
      @@valid.sighting_type(type)
    end

    def self.valid_date(date)
      @@valid.date(date)
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

    def country
      @country.to_s
    end

    def city
      @city.to_s
    end

    def sighting_type
      @sighting_type.to_s
    end
  end
end
