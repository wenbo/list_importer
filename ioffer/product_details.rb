module Ioffer
  module ProductDetails
    include Ioffer::Photos
    def get_detail_and_photo
      detail_url = "http://www.ioffer.com" + self.product.origin_url
      p detail_url
      detail_page = Mechanize.new.get(detail_url)
      assign_detail(detail_page)
      assign_photo(detail_page)
    end

    def assign_detail(detail_page)
      long_desc = (detail_page/"div[@id='itemDetailTabContent']").inner_html #removed center
      self.update_attribute(:long_desc, long_desc)
    end
  end
end
