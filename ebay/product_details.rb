module Ebay
  module ProductDetails
    include Ebay::Photos
    include Ebay::Shippings
    
    def get_detail(origin_url, free_category_id, standard_category_id)
      detail_page = get_detail_page(origin_url)
      if detail_page
        assign_category_id(detail_page)
        if assign_long_desc(detail_page)
          get_shipping_detail(detail_page, free_category_id, standard_category_id)
          assign_photo(detail_page)
        end
      end
    end

    def get_detail_page(origin_url)
      begin
        detail_page = Mechanize.new.get(origin_url)
      rescue Mechanize::ResponseCodeError
        self.product.update_attribute(:deleted_at, Time.now)
        return false
      end
    end
    
    def assign_category_id(detail_page)
      cats = get_cat_names(detail_page)
      cats.reverse.each do |cat_name|
        category = Category.find_by_name cat_name.gsub(/&amp;/, "&")
        if category
          self.product.update_attribute(:category_id, category.id)
          break
        end
      end
    end

    def get_cat_names(detail_page)
      cat_a_nodes = (detail_page.search("//table[@class='vi-ih-area_nav']")/"table"/"ul"/"a")
      if cat_a_nodes.blank?
        cat_a_nodes = (detail_page.search("//table[@class='vi-ih-area_nav']")/"table"/"ul"/"li"/"span:first-child")
      end
      cat_a_nodes.collect do |cat|
        cat.inner_html
      end
    end

    def assign_long_desc(detail_page)
      tidy_desc = detail_page.search("//div[@class='item_description']").inner_html
      long_desc = ProductDetail.clean_with_tidy(tidy_desc)
      if long_desc.blank? || detail_page.body.include?("This listing has ended")
        Product.update(self.product_id, :deleted_at => Time.now)
        return false
      else
        self.update_attribute(:long_desc, long_desc)
      end
    end
    
  end
end
