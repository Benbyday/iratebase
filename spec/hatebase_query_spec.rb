require "hate_query"

describe HateQuery do
  context "when no key given" do
    it "should initialize an empty string" do
      hq = HateQuery.new
      expect(hq.key).to eql ""
    end
  end
end
