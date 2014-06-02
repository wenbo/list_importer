require 'spec_helper'

describe Ebay::Products do
  before(:each) do
    @store = Factory(:store)
    @store.extend Ebay::Importer
    @importer = Factory(:importer, :origin => "eBay", :user_name => "esbuys") #patricial9138
    @store.importers << @importer
    user_url = "http://myworld.ebay.com/#{@importer.user_name}"
    user_doc = Mechanize.new.get(user_url)
    @store_url = @store.get_store_url(user_doc)
  end

  it "#get_pages" do
    urls = @store.get_pages(@store_url)
    p urls.size
    urls.size.should be >= 1
  end

  it "#get_products then #get_product" do
    product_nodes = @store.get_products(@store_url)
    product_nodes.size.should > 1
    item = product_nodes.first 
    pro = @store.get_product(item)
    pro.name.should_not be_blank
    pro.origin_url.should_not be_blank
    pro.sell_price.should_not be_blank
  end

end
