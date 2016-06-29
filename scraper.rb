require 'open-uri'
require 'nokogiri'
require 'kconv'

class InvalidPageException < Exception; end

class Scraper
    attr_reader :html, :doc, :url
    def initialize url
        @url = url
        charset = nil
        begin
            @html = open(url) do |f|
                charset = f.charset
                f.read.toutf8
            end
        rescue
            raise InvalidPageException
        end
        @doc = Nokogiri::HTML.parse(html)#,nil,charset)
        raise InvalidPageException if @doc.nil?
    end
end
