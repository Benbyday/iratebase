module Iratebase
  class Valid
    def from_regex(name, rex)
      if !(name.is_a?(Symbol) && rex.is_a?(Regexp))
        return nil
      end
      p = Proc.new do |str|
        m = rex.match(str)
        if m == nil
          false
        else
          m.to_s == str
        end
      end
      self.class.send(:define_method, name, p)
    end
  end
end
