module Ioffer
  module Photos
    
    def parse_img_src(detail_page)
      table = detail_page/"table[@class='item-detail-top-table']"
      detail_img_src = table.inner_html.match(/itemDetailSetMainImage\(.*\)/).to_s.match(/'(.*?)'/)[1]
    end

    def assign_photo(detail_page)
      detail_img_src = parse_img_src(detail_page)
      detail_img_basename = detail_img_src.split("/").last
      url = URI.parse(detail_img_src)
      begin
        resp = Net::HTTP.get_response(url)
        file_path = File.join(RAILS_ROOT, "public", "asset", "importer", detail_img_basename)
        File.open(file_path, "a+") { |file|
          file.write(resp.body)
        }
        photo = Photo.new(
          :store_id => self.product.store_id,
          :avatar => File.new(file_path)
        )
        photo.save
        self.product.photos << photo
        FileUtils.rm file_path
      end
    end
    
  end
end
