require 'pry'
require 'date'

module Blergers
  class Importer
    attr_reader :dir, :posts

    def initialize(dir)
      @dir = dir
      @posts = []
    end

    def parse_header(file)
      metadata = {}
      file.readline
      4.times do
        line = file.readline.chomp.split(": ")
        key, value = line[0].to_sym, line[1]
        metadata[key] = value
      end
      metadata[:date] = DateTime.parse(metadata[:date])
      metadata[:tags] = metadata[:tags].split(", ")
      file.readline
      metadata
    end

    def import_post(file)
      result = self.parse_header(file)
      result[:content] = file.read
      result
    end

    def import
      Dir.glob("#{dir}/*.post").each do |path|
        File.open(path, 'r') do |f|
          @posts << self.import_post(f)
        end
      end
    end
  end
end
