require 'spec_helper'

describe Ebay::Photos do
  before(:each) do
    @product = Factory(:product, :name => "BOYS BOAT SHIP MARITIME/SEA TODDLER COT BED CHILDS KIDS",
      :origin_url => "http://cgi.ebay.com/1700mAh-Battery-BST-37-Sony-Ericsson-Z520-Z710-D750-/180530883910?pt=AU_MobilePhoneAccessories&hash=item2a087aad46")
    @product.extend Ebay::ProductDetails
  end

  it "#parse img src" do
    detail_page = Mechanize.new.get(@product.origin_url) 
    src = @product.parse_img_src(detail_page)
    src.should match /^http(.)+(jpg|gif|jpef|png)/
  end

end
