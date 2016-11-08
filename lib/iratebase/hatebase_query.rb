class HateQuery
  def initialize(key = "")
    @key = "#{key}"
  end
  def key
    return String.new(@key)
  end
end
