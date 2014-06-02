require 'spec_helper'

describe Ebay::Feedbacks do
  before(:each) do
    @store = Factory(:store, :user => Factory(:user))
    @importer = Factory(:importer, :origin => "eBay", :user_name => "cute.panda")
    @store.importers << @importer
    @store.extend  Ebay::Importer
  end
  
  it "gets feedback info" do
    user_url = "http://myworld.ebay.com/#{@importer.user_name}"
    user_doc = Mechanize.new.get(user_url)
    @store.update_feedback_score_and_count(user_doc)
    puts @store.feedback_info.attributes
  end

end
