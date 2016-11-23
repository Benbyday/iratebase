module Iratebase
  class Datapoint
    @@keys = {
      :sighting_id => :integer,
      :date => :datetime,
      :country => :string,
      :city => :string,
      :lat => :string,
      :long => :string,
      :type => :string,
      :human_readable_type => :string,
      :vocabulary => :string,
      :variant_of => :string,
      :pronunciation => :string,
      :meaning => :string,
      :language => :string,
      :about_ethnicity => :boolean,
      :about_nationality => :boolean,
      :about_religion => :boolean,
      :about_gender => :boolean,
      :about_sexual_orientation => :boolean,
      :about_disability => :boolean,
      :about_class => :boolean,
      :archaic => :boolean,
      :offensiveness => :float,
      :number_of_revisions => :integer,
      :number_of_variants => :integer,
      :variants => :string,
      :number_of_sightings => :integer,
      :last_sighting => :datetime,
      :number_of_citations => :integer
    }

    @@keys.each do |key, type|
      p = Proc.new do
        value = @datapoint[key.to_s]
        if value.is_a? Hash && (value.empty? || value.has_key("0"))
          return nil
        end
        case type
        when :string
          "#{value}"
        when :integer
          value.to_i
        when :boolean
          value.to_i == 1
        when :float
          value.to_f
        when :date
          Date.parse(value)
        when :datetime
          DateTime.parse(value)
        end
      end
      define_method(key, p)
    end

    def initialize(data)
      @datapoint = data
    end

    def datapoint
      @datapoint
    end
  end
end
