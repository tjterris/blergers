require 'pry'

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "blergers/version"
require 'blergers/init_db'
require 'blergers/importer'

module Blergers
  class Post < ActiveRecord::Base
    has_many :post_tags
    has_many :tags, through: :post_tags

    def self.page(n, page_size=10)
      page_offset = (n - 1) * page_size
      Post.order(date: :desc).offset(page_offset).limit(page_size)
    end

    def tweeter
      self.content[0, 140]
    end
  end

  class Tag < ActiveRecord::Base
    has_many :post_tags
    has_many :posts, through: :post_tags

    def self.top_tags
      # Tag.all.map { |x| [x.name, x.posts.count] }.sort_by { |x| x[1] }.reverse
      # Blergers::Tag.joins(:post_tags).
      #   group_by {|x| x.name }.
      #   map {|k, v| [k, v.length]}.
      #   sort_by {|x| x[1] }.
      #   reverse
      # Tag.joins(:post_tags).group("tags.name").count.sort_by { |x| x[1] }.reverse
      Tag.joins(:post_tags).group(:name).order("count_all DESC").count
      ## The above ActiveRecord command generates the following SQL:
      # sqlite> SELECT tags.*, COUNT(*) as count_all FROM TAGS
      #    ...>   INNER JOIN post_tags ON post_tags.tag_id = tags.id
      #    ...>   GROUP BY tags.name ORDER BY count_all;
    end

    def self.count_tagged_with(*tag_names)
      # OH NOES! Overcounting for posts with more than one of tag_names!
      # Tag.joins(:post_tags).where(name: tag_names).count
      Tag.joins(:post_tags).where(name: tag_names).group(:post_id).count.count
    end
  end

  class PostTag < ActiveRecord::Base
    belongs_to :post
    belongs_to :tag
  end
end

def add_post!(post)
  puts "Importing post: #{post[:title]}"

  tag_models = post[:tags].map do |t|
    Blergers::Tag.find_or_create_by(name: t)
  end
  post[:tags] = tag_models

  post_model = Blergers::Post.create(post)
  puts "New post! #{post_model}"
end

def run!
  blog_path = '/Users/brit/projects/improvedmeans'
  toy = Blergers::Importer.new(blog_path)
  toy.import
  toy.posts.each do |post|
    add_post!(post)
  end
end

binding.pry