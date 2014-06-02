require 'spec_helper'

describe Ioffer::Photos do

  before(:each) do
    @product = Factory(:product, :name => "CHLOES fashion Women's sunglasses CHLOES",
      :origin_url => "/i/sex-the-city-carrie-irregular-oblique-dinner-dress-se-158349189")
    @product.extend Ioffer::ProductDetails
  end

  it "#parse img src" do
    detail_url = "http://www.ioffer.com" + @product.origin_url
    detail_page = Mechanize.new.get(detail_url) 
    src = @product.parse_img_src(detail_page)
    src.should match /^http(.)+(jpg|gif|jpef|png)/
  end
  
end
