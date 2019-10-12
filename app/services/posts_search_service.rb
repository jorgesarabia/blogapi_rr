# frozen_string_literal: true

class PostsSearchService
  def self.search(curr_posts, query)
    curr_posts.where("title like '%#{query}%'")
  end
end
