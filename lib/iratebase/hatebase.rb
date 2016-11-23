module Iratebase
  class Hatebase
    @@keys = {:version => :string,
      :status => :string,
      :number_of_results => :integer,
      :warnings => :hash,
      :errors => :hash,
      :number_of_queries_today => :integer,
      :data => :hash}

    @@keys.each do |key, type|
      p = Proc.new do
        value = @hatebase[key.to_s]
        if value.is_a? Hash
          if value.empty? or value.has_key?("0")
            return nil
          end
        end
        case type
        when :string
          "#{value}"
        when :integer
          value.to_i
        when :hash
          value.clone
        end
      end
      define_method(key, p)
    end

    def initialize(hate)
      @hatebase = nil
      errors = hate["errors"]
      if errors.has_key?("error_code")
        raise Iratebase::HatebaseError.exception errors["human_readable_error"]
      end
      hate.delete("page")
      hate.delete("number_of_results_on_this_page")
      hate["data"] =
        hate["data"]["datapoint"].map {|point| Iratebase::Datapoint.new point}
      @hatebase = hate
    end

    def join(hate)
      if not hate.is_a? Iratebase::Hatebase
        raise "Can only join two Hatebases."
      end
      @hatebase["data"] = hate.data + @hatebase["data"]
      self
    end

    def to_json
      red = self.data
      und = red.map {|datapoint| datapoint.datapoint}
      @hatebase["data"] = {"datapoint" => und}
      json = JSON.generate(@hatebase)
      @hatebase["data"] = red
      json
    end
  end
end
