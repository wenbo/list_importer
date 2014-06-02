require 'spec_helper'

describe Ebay::Feedbacks do
  before(:each) do
    @store = Factory(:store, :user => Factory(:user))
    @importer = Factory(:importer, :origin => "eBay", :user_name => "qywsq")
    @store.importers << @importer
    @store.extend  Ebay::Importer
  end
  
  it "gets feedback urls" do
    user_url = "http://myworld.ebay.com/#{@importer.user_name}"
    user_doc = Mechanize.new.get(user_url)
    urls = @store.get_feedback_urls(user_doc)
    puts urls.size
    urls.size.should be >= 1
  end
  
  it "assgins feedback attributes" do
    user_url = "http://myworld.ebay.com/#{@importer.user_name}"
    user_doc = Mechanize.new.get(user_url)
    urls = @store.get_feedback_urls(user_doc)
    @store.counter = 0
    feedback_url = urls.first
    @store.get_feedback_by(feedback_url)
  end 

  it "should update feedback score and count)" do 
    user_url = "http://www.ioffer.com/users/#{@importer.user_name}"
    user_doc = Mechanize.new.get(user_url)
    @store.update_feedback_score_and_count(user_doc)
  end

end
