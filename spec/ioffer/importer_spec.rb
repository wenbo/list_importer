require 'spec_helper'

describe ListImporter do
  before(:each) do
    @store = Factory(:store)
    @importer = Factory(:importer, :origin => "iOffer", :user_name => "yuyuqw")
    @store.importers << @importer
    @store.extend Ioffer::Importer
  end

  it "should desc" do
   # Store.import(:products, @importer)
  end
  

end
