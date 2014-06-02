require 'spec_helper'

describe Ioffer::Products do
  before(:each) do
    @store = Factory(:store)
    @store.extend Ioffer::Importer
    @importer = Factory(:importer, :origin => "iOffer", :user_name => "yuyuqw")
    @store.importers << @importer
    username = @importer.user_name
    @store_url = "http://www.ioffer.com/selling/" + username 
  end

  it "gets products urls" do
    urls = @store.get_pages(@store_url)
    urls.size.should be > 1
    page = urls.first
    @store.get_product(page)
  end

end
