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

    @@vocab_filt = [:vocabulary, :variant_of, :language]

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
      # create setters that work like normal setters and check to make sure the
      # filter is of the correct form. These are of the form #{filter}=
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
      # create setters that do exactly the same thing but return the self
      # object after setting in order to be able to do complex things in one
      # line. These are of the form set_#{filter}
      swift_set = ("set_" + filter.to_s).to_sym
      ss = Proc.new do |set|
        self.method(basic_set).call(set)
        self
      end
      define_method(swift_set, ss)
      # create getters. These are of the form of just #{filter}
      get = Proc.new do
        str = inxtance_variable_get("@#{filter}")
        "#{str}"
      end
      define_method(filter, get)
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

    def flags_string
      if @relevant_flags <= 0
        return "any word or sighting"
      end
      str = "word or sighting that"
      is = self.is_flags
      is_not = self.is_not_flags
      if !is.empty?
        isst = is.to_s
        str += " is " + isst[1, isst.length - 2]
      end
      if !is.empty? && !is_not.empty?
        str += " and"
      end
      if !is_not.empty?
        isnt = is_not.to_s
        str += " is not " + isnt[1, isnt.length - 2]
      end
      str
    end

    def is_flags
      is = []
      if @relevant_flags <= 0
        return is
      end
      (Math.log2(@relevant_flags).floor + 1).times do |f|
        flag = 2**f
        if @relevant_flags & @flag_values & flag == flag
          is << @@flags.key(flag)
        end
      end
      return is
    end

    def is_not_flags
      is_not = []
      if @relevant_flags <= 0
        return is_not
      end
      (Math.log2(@relevant_flags).floor + 1).times do |f|
        flag = 2**f
        if @relevant_flags & ~@flag_values & flag == flag
          is_not << @@flags.key(flag)
        end
      end
      return is_not
    end

    # doers
    def to_s
      if key == ''
        raise KeyError.exception 'a key must be a 32 digit hexadecimal '\
            'number. You can obtain a key from '\
            'https://www.hatebase.org/login_register/redirect/request_api'
      end
      if @query_type == nil
        raise FilterError.exception 'you must decide if you are searching for'\
            'vocabulary or sightings'
      end
      query = "https://api.hatebase.org/" + self.version + "/" + self.key +
          "/" + self.query_type + "/" + self.output + "/"
      filt_arr = []
      if self.query_type == "vocabulary"
        filt_arr = @@vocab_filt
      else
        filt_arr = @@filters.keys
      end
      f = filt_arr.reduce("") do |prev, filter|
        val = self.instance_variable_get('@' + filter.to_s)
        if val != nil
          prev += "%7C" + filter.to_s + "%3D" + URI.encode(val.to_s)
        end
        prev
      end
      f += self.is_flags.reduce("") do |prev, flag|
        prev += "%7C" + flag.to_s + "%3D1"
      end
      f += self.is_not_flags.reduce("") do |prev, flag|
        prev += "%7C" + flag.to_s + "%3D0"
      end
      query += f[3, f.length]
      query
    end

    def get_query
      uri = URI.parse(self.to_s)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      res = http.get(uri.request_uri)
      str = res.body()
      obj = JSON.parse(str)
      obj
    end
  end
end
