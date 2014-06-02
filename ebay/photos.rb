module Ebay
  module Photos

    def parse_img_src(detail_page)
      detail_img_div = detail_page.search("//div[@class='ic-w300 ic-m']")
      image = (detail_img_div/"img").first
      return nil if image.nil?
      image.attributes["src"].value
    end

    def download_img(detail_img_src)
      img_url = URI.parse(detail_img_src)
      detail_img_basename = detail_img_src.split("/").last
      return if File.exist? detail_img_basename
      resp = Net::HTTP.get_response(img_url)
      file_path = File.join(RAILS_ROOT, "public", "asset", "importer", detail_img_basename)
      File.open(file_path, "a+") { |file|
        file.write(resp.body)
      }
      matched_aspx = resp.body.match(/href=\"(http:.*aspx.*)\"/)
      if matched_aspx
        FileUtils.rm file_path if File.exists? file_path
        detail_img_src = matched_aspx[1]
        detail_img_basename = detail_img_src.match(/=(.*)$/)[1] << ".JPG"
        img_url = URI.parse(detail_img_src)
        resp = Net::HTTP.get_response(img_url)
        file_path = File.join(RAILS_ROOT, "public", "asset", "importer", detail_img_basename)
        File.open(file_path, "a+") { |file|
          file.write(resp.body)
        }
      end
      if detail_img_basename.match(/ViewImage\.aspx\?/)
        file_path_b = File.join(RAILS_ROOT, "public", "asset", "importer", (detail_img_basename.match(/=(.*)$/)[1] << ".JPG"))  
        File.rename(file_path, file_path_b)
        file_path = file_path_b
      end
      file_path
    end

    def assign_photo(detail_page)
      detail_img_src = parse_img_src(detail_page)
      return if detail_img_src.nil?
      file_path = download_img(detail_img_src)
      photo = Photo.new(
        :store_id => self.product.store_id,
        :avatar => File.new(file_path)
      )
      photo.save
      self.product.photos << photo
      FileUtils.rm file_path if File.exists? file_path
    end
  end
  
end
