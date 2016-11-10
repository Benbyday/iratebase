class HateQuery
  def initialize(key = "")
    self.key = key
    @version = 3
    @subversion = 0
    @query_type = nil
    @output = :json
  end

  # Class methods
  def self.valid_key(key)
    /[0-9a-f]{32}/ === key
  end

  # Setters and getters
  def key
    return String.new(@key)
  end

  def key=(key)
    if key == "" || HateQuery.valid_key(key)
      @key = "#{key}"
    else
      @key = ""
    end
  end

  def version
    "v" + @version.to_s + "-" + @subversion.to_s
  end

  def query_type
    @query_type.to_s
  end

  def output
    @output.to_s
  end
end
