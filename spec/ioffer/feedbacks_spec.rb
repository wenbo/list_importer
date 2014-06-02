require 'spec_helper'

describe Ioffer::Feedbacks do
  before(:each) do
    @store = Factory(:store, :user => Factory(:user))
    @importer = Factory(:importer, :origin => "iOffer", :user_name => "esbuys")
    @store.importers << @importer
    @store.extend  Ioffer::Importer
  end
  
  it "gets feedback urls" do
    urls = @store.get_feedback_urls(@importer.user_name)
    urls.size.should be >= 1
  end
  
  it "assgins feedback attributes" do
    urls = @store.get_feedback_urls(@importer.user_name)
    feedback_url = urls.first
    @store.get_feedback_by(feedback_url)
  end 

  it "gets total number of ratings url element" do
    user_url = "http://www.ioffer.com/users/#{@importer.user_name}"
    user_doc = Mechanize.new.get(user_url)
    ratings_url = @store.get_ratings_url_element(user_doc)
    ratings_url.text.to_i.should >= 0
  end
  
  it "should update feedback score and count)" do 
    user_url = "http://www.ioffer.com/users/#{@importer.user_name}"
    user_doc = Mechanize.new.get(user_url)
    @store.update_feedback_score_and_count(user_doc)
  end

end
