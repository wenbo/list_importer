require 'spec_helper'

describe ListImporter do
  before(:each) do
    @store = Factory(:store)
    @store.extend Ebay::Importer  
    @importer = Factory(:importer, :user_name => "ausnetauctions")#, esbuys ausnetauctions,:user_name => 'bpatricial9138', :origin => "eBay") # bpatricial9138 beltal, love_to_trade_junk
    @store.importers << @importer
  end

  it "should import product and feedback" do
    @store.import(:products, @importer)
  end
end

