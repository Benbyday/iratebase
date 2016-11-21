module Iratebase
  class QueryError < RuntimeError
  end

  class KeyError < QueryError
  end

  class FilterError < QueryError
  end

  class HatebaseError < RuntimeError
  end
end
