require 'spec_helper'

describe Ebay::Shippings do
  before(:each) do
    @detail = Factory(:product_detail)
    @product = Factory(:product,
      :name => "BOYS BOAT SHIP MARITIME/SEA TODDLER COT BED CHILDS KIDS",
      :origin_url => "http://cgi.ebay.com/100-pcs-46mm-Gold-Plated-RCA-Plug-Monster-Cable-R-B-/230547828920?pt=LH_DefaultDomain_0&hash=item35adb8b0b8",
      :product_detail => @detail
    )
    @detail.extend Ebay::Shippings
  end

  it "import_detail" do
    @detail.get_shipping_detail(@product.origin_url, 1, 1)
  end

end

