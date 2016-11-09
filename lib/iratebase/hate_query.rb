class HateQuery
  def initialize(key = "")
    @key = "#{key}"
  end
  def self.valid_key(key)
    /[0-9a-f]{32}/ === key
  end
  def key
    return String.new(@key)
  end
end
