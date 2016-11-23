require "iratebase"
require "pry"
require "pry-byebug"

HateQuery = Iratebase::HateQuery

describe HateQuery do
  context "when creating a new query and no key is given" do
    def new_query
      HateQuery.new
    end
    it "initializes an empty string" do
      expect(new_query.key).to eql ""
    end
    it "sets the version to the default" do
      expect(new_query.version).to eql "v3-0"
    end
    it "does not assume query type" do
      expect(new_query.query_type).to eql ""
    end
    it "sets default output as json" do
      expect(new_query.output).to eql "json"
    end
    it "accepts a valid api key" do
      hq = new_query
      key = "1234567890abcdef1234567890abcdef"
      hq.key = key
      expect(hq.key).to eql key
      key = "fedcba0987654321fedcba0987654321"
      expect(hq.set_key(key).key).to eql key
    end
    it "rejects an invalid api key" do
      hq = new_query
      key = "1234567890abcdef1234567890abcdeg"
      expect{hq.set_key(key)}.to raise_error(Iratebase::KeyError)
      expect(hq.key).to eql ""
    end
  end
  context "in standard use" do
    it "one can set up a new query in one line" do
      key = "1234567890abcdef1234567890abcdef"
      hq = HateQuery.new(key).vocab
      expect(hq.key).to eql key
      expect(hq.version).to eql "v3-0"
      expect(hq.query_type).to eql "vocabulary"
      expect(hq.output).to eql "json"
    end
    it "is easy to set the version in one line" do
      key = "1234567890abcdef1234567890abcdef"
      hq = HateQuery.new(key).vocab.set_version(2,5)
      expect(hq.version).to eql "v2-5"
      hq.set_version(3)
      expect(hq.version).to eql "v3-0"
    end
    it "properly handles flags" do
      hq = HateQuery.new.is("about_gender")
      expect(hq.flags_string).to eql "word or sighting that is :about_gender"
      hq = HateQuery.new.is("about_religion").is_not("about_gender")
      expect(hq.flags_string).to eql "word or sighting that is :about_religion"\
                                     " and is not :about_gender"
      hq.forget("about_gender", "about_religion")
      expect(hq.flags_string).to eql "any word or sighting"
      hq.is("about_class").is_not("about_class")
      expect(hq.flags_string).to eql "word or sighting that is not :about_class"
    end
  end
  context "when a simple query is complete" do
    it "produces the simplest query" do
      key = "1234567890abcdef1234567890abcdef"
      hq = HateQuery.new(key).vocab
      expect(hq.to_s).to eql "https://api.hatebase.org/v3-0/" + key +
          "/vocabulary/json/language%3Deng"
      hq = HateQuery.new(key).sightings
      expect(hq.to_s).to eql "https://api.hatebase.org/v3-0/" + key +
          "/sightings/json/language%3Deng%7Ccountry%3DUS"
    end
    it "rejects a fake key" do
      #key = Iratebase.find_key('../')
      key = "1234567890abcdef1234567890abcdef"
      hq = HateQuery.new(key).vocab
      expect{hq.get_query}.to raise_error(Iratebase::HatebaseError)
    end
    # it "successfully returns a hatebase object regardless of key filters" do
    #   key = Iratebase.find_key("../")
    #   hq = HateQuery.new(key).vocab
    #   binding.pry
    #   hate = hq.get_query
    #   expect(hate.is_a? Iratebase::Hatebase).to be true
    #   hq.sightings
    #   hate = hq.get_query
    #   expect(hate.is_a? Iratebase::Hatebase).to be true
    # end
  end
  it "knows what a valid key looks like" do
    keys = {"1234567890abcdef1234567890abcdef" => true,
           "1" => false,
           "fedcba0987654321fedcba098765432" => false,
           "1234567890abcdef1234567890abcdeg" => false}
    keys.each{|key, value| expect(HateQuery.valid_key(key)).to be value}
  end
  it "knows what a valid vocab word looks like" do
    words = {"aligator bait" => true,
            "Aunt Jane" => true,
            "bans and cans" => true,
            "Afro-Saxon" => true,
            "this will FA1L" => false,
            "don\'t pass" => false}
    words.each do |word, value|
      expect(HateQuery.valid_vocabulary(word)).to be value
    end
  end
  it "knows what a valid language code looks like" do
    words = {"abc" => true,
             "eng" => true,
             "1bc" => false,
             "" => false,
             nil => false,
             "a" => false,
             "ENG" => false,
             "Eng" => false,
             "toolong" => false,
             "--------" => false,
             "---" => false}
    words.each do |word, value|
      expect(HateQuery.valid_language(word)).to be value
    end
  end
  it "knows what a valid country code looks like" do
    words = {
      "AB" => true,
      "US" => true,
      "us" => false,
      "12" => false,
      "1A" => false,
      "" => false,
      nil => false,
      "A" => false,
      "HOWABOUTTHAT" => false,
      "123" => false
    }
    words.each do |word, value|
      expect(HateQuery.valid_country(word)).to be value
    end
  end
  it "knows what a valid sighting type looks like" do
    words = {
      "r" => true,
      "o" => true,
      "u" => true,
      "t" => true,
      "" => false,
      nil => false,
      "a" => false,
      "R" => false,
      "ro" => false,
      "abc" => false
    }
    words.each do |word, value|
      expect(HateQuery.valid_sighting_type(word)).to be value
    end
  end
  it "knows what a valid date looks like" do
    dates = {
      "1234-56-78" => true,
      "2016-01-01" => true,
      "abcd-ef-gh" => false,
      "12-34-5678" => false,
      "" => false,
      "2016-01" => false,
      nil => false,
      "hello" => false,
      "1234-56-789" => false,
      "12345-67-89" => false,
      "completely wrong thing" => false
    }
    dates.each do |date, value|
      expect(HateQuery.valid_date(date)).to be value
    end
  end
end
