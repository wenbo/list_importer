require 'spec_helper'

describe Ioffer::ProductDetails do
  before(:each) do
    @product = Factory(:product, :name => "CHLOES fashion Women's sunglasses CHLOES",
      :origin_url => "/i/sex-the-city-carrie-irregular-oblique-dinner-dress-se-158349189",
      :product_detail => Factory(:product_detail)
    )
  end

  it "import_detail" do
    ProductDetail.import_detail
  end

end
