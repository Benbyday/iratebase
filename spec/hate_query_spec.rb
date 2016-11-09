require "iratebase/hate_query"

describe HateQuery do
  context "when no key given" do
    it "should initialize an empty string" do
      hq = HateQuery.new
      expect(hq.key).to eql ""
    end
  end
  it "should know what a valid key looks like" do
    key = "1234567890abcdef1234567890abcdef"
    expect(HateQuery.valid_key(key)).to be true
  end
end
