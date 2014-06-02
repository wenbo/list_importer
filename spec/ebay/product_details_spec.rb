require 'spec_helper'

describe Ebay::ProductDetails do
  before(:each) do
    @detail = Factory(:product_detail)
    @product = Factory(:product,
      :name => "BOYS BOAT SHIP MARITIME/SEA TODDLER COT BED CHILDS KIDS",
      :origin_url => "http://cgi.ebay.co.uk/Rocket-Stagg-Plastic-Finger-Castanets-Pair-/200545784018?pt=UK_Musical_Instruments_Drums_Percussions_MJ&hash=item2eb175d0d2",
      :product_detail => @detail
    )
    ProductDetail.class_eval do 
      include Ebay::ProductDetails
    end
  end

  it "#get_detail" do
    @detail.get_detail(@product.origin_url, 1, 1)
  end

end

