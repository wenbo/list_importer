module Ioffer
  module Feedbacks

    def import_feedbacks(username, user_doc)
      ratings_url_element = get_ratings_url_element(user_doc)
      unless ratings_url_element.blank?
        update_feedback_score_and_count(ratings_url_element)
      end

      feedback_urls = get_feedback_urls(username)
      unless feedback_urls.blank?
        save_feedbacks(feedback_urls)
      end
    end

    def get_ratings_url_element(user_doc)
      (user_doc.search("//div[@id='profileMeetTheSeller']")/"a").last
    end

    def save_feedbacks(feedback_urls)
      feedback_urls.each do |feedback_url|
        get_feedback_by feedback_url
      end
    end

    def update_feedback_score_and_count(ratings_url_element)
      begin
        self.build_feedback_info unless self.feedback_info
        self.feedback_info.feedbacks_count = ratings_url_element.text.to_i
        ratings_url = ratings_url_element.attributes["href"].value
        ratings_doc = Mechanize.new.get(ratings_url)
        ratings_table = ratings_doc.search("//table[@class='seller-summary-table verdana']")
        ratings_trs = ratings_table/"tr"

        pos_tds = ratings_trs[1]/"td"
        self.feedback_info.month_positive_count = pos_tds[2].text.strip
        self.feedback_info.half_year_positive_count = pos_tds[3].text.strip
        self.feedback_info.year_positive_count = pos_tds[4].text.strip

        neu_tds = ratings_trs[3]/"td"
        self.feedback_info.month_neutral_count = neu_tds[1].text.strip
        self.feedback_info.half_year_neutral_count = neu_tds[2].text.strip
        self.feedback_info.year_neutral_count = neu_tds[3].text.strip

        neg_tds = ratings_trs[4]/"td"
        self.feedback_info.month_positive_count = neg_tds[1].text.strip
        self.feedback_info.half_year_positive_count = neg_tds[2].text.strip
        self.feedback_info.year_positive_count = neg_tds[3].text.strip
        self.save
      rescue
        return
      end
    end

    def get_feedback_by(feedback_url)
      feedback_doc = Mechanize.new.get(feedback_url)
      feedback_tables = feedback_doc.search("//table[@class='rating_table']")
      feedback_tables.each do |feedback_table|
        feedback_tds = ((feedback_table/"tr").first/"td")
        hash = {}
        begin
          rank_img_alt = (feedback_tds[0]/"img").first.attributes["alt"].value
          hash[:rank] = case rank_img_alt
          when "Positive Transaction"
            1
          when "Unrated Transaction"
            nil
          end
          hash[:text] = ((feedback_tds[2]/"div").first/"a").inner_html
          hash[:member_id] = ((feedback_tds[2]/"div")[3]/"a").text
          hash[:product_name] = ((feedback_tds[2]/"div")[1]/"a").inner_html
          hash[:product_price] = ((feedback_tds[2]/"div")[1]/"span span").text
        rescue
          next
        end
        assign_feedback(hash)
      end
    end

    def assign_feedback(hash)
      Feedback.create(
        :store_id => self.id,
        :rating => hash[:rank],
        :buyer => hash[:member_id],
        :product_name => hash[:product_name],
        :content => hash[:text],
        :price => hash[:product_price].delete("$")#match(/\d*\.\d*/).to_s
      )
      self.counter += 1
    end

    def get_feedback_urls(username)
      feedback_urls = []
      #    username = "ima.products"
      # user_url = "http://www.ioffer.com/ratings/ima.products"
      begin
        feedback_url = "http://www.ioffer.com/ratings/" + username
        feedback_urls << feedback_url
        feedback_doc = Mechanize.new.get(feedback_url)
        feedback_pgn = feedback_doc.search("//div[@class='pagination']")
        link_count = (feedback_pgn/"a").size
        if link_count > 2
          last_pg_number = (feedback_pgn/"a")[link_count-2].inner_html.to_i
          2.upto last_pg_number do |i|
            pg_url = feedback_url + "?page=" + i.to_s
            feedback_urls << pg_url
          end
        end
        feedback_urls
      end
    end
  end
end



  
