require "iratebase"
require "pry"
require "pry-byebug"

HateQuery = Iratebase::HateQuery

describe HateQuery do
  context "when creating a new query and no key is given" do
    def new_query
      HateQuery.new
    end
    it "should initialize an empty string" do
      expect(new_query.key).to eql ""
    end
    it "should set the version to the default" do
      expect(new_query.version).to eql "v3-0"
    end
    it "should not assume query type" do
      expect(new_query.query_type).to eql ""
    end
    it "should set default output as json" do
      expect(new_query.output).to eql "json"
    end
    it "should accept a valid api key" do
      hq = new_query
      key = "1234567890abcdef1234567890abcdef"
      hq.key = key
      expect(hq.key).to eql key
      key = "fedcba0987654321fedcba0987654321"
      expect(hq.set_key(key).key).to eql key
    end
    it "should reject an invalid api key" do
      hq = new_query
      key = "1234567890abcdef1234567890abcdeg"
      expect{hq.set_key(key)}.to raise_error(HateQuery::KeyError)
      expect(hq.key).to eql ""
    end
  end
  context "in standard use" do
    it "should be easy to set up a new query in one line" do
      key = "1234567890abcdef1234567890abcdef"
      hq = HateQuery.new(key).vocab
      expect(hq.key).to eql key
      expect(hq.version).to eql "v3-0"
      expect(hq.query_type).to eql "vocabulary"
      expect(hq.output).to eql "json"
    end
  end
  it "should know what a valid key looks like" do
    keys = {"1234567890abcdef1234567890abcdef" => true,
           "1" => false,
           "fedcba0987654321fedcba098765432" => false,
           "1234567890abcdef1234567890abcdeg" => false}
    keys.each{|key, value| expect(HateQuery.valid_key(key)).to be value}
  end
  it "should know what a valid vocab word looks like" do
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
  it "should know what a valid language code looks like" do
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
end
