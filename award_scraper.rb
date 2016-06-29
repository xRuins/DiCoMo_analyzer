require './scraper.rb'
require './authors_name_parser.rb'
require 'byebug'
require 'sanitize'

class AwardsScraper < Scraper
    def initialize url, year
        super(url)
        @year = year
    end

    def get_best_presentation_awards
        nominated_titles = []
        best_presentation_awards_begun = false
        if @year == 2013
            @doc.xpath('//*[@id="left_content"]/div/ul/table[3]/tr/td').each do |td| # best paper award
                td_text = td.text
                nominated_titles << td_text if title_filter(td_text)
            end
        elsif @year >= 2014
            content = @doc.xpath('//*[@id="content"]/div/table[1]/tbody').text.toutf8.split("\n")
            content.each do |td_text|
                nominated_titles << td_text if title_filter(td_text)
            end
        else
            get_content_text.each  do |line|
                line_type = match_awards_line(line)
                best_presentation_awards_begun = true if line_type == :best_presentation_awards
                break if line_type == :presentation_awards
                next unless best_presentation_awards_begun # ignore lines until the line of best presentation awards appears
                title = get_title_from_line line
                nominated_titles << title if title
            end
        end
        return nominated_titles
    end

    def title_filter string
        !(string.match(/^[0-9A-Z-].*$/) or string.match(/.*[\(（].*[\)）].*$/) or string.match(/^$/))
    end

    def get_presentation_awards
        nominated_titles = []
        presentation_awards_begun = false
        if @year == 2013
            @doc.xpath('//*[@id="left_content"]/div/ul/table[4]/tr/td').each do |td| #  paper award
                td_text = td.text
                nominated_titles << td_text if title_filter(td_text)
            end
        elsif @year >= 2014
            content = @doc.xpath('//*[@id="content"]/div/table[2]/tbody').text.toutf8.split("\n")
            content.each do |td_text|
                nominated_titles << td_text if title_filter(td_text)
            end
        else
            get_content_text.each  do |line|
                line_type = match_awards_line(line)
                presentation_awards_begun = true if line_type == :presentation_awards
                break if line_type == :young_researcher_awards
                next unless presentation_awards_begun # ignore lines until the line of presentation awards appears
                title = get_title_from_line line
                nominated_titles << title if title
            end
        end
        return nominated_titles
    end

    def get_content_text
        content = @doc.xpath('//*[@id="left_content"]')
        content.text.toutf8.split("\r\n")
    end

    def get_title_from_line line
        if matched_line = line.match(/^[0-9A-Z\-]+[[:space:]]+(.*)$/)
            title = $1
            if title.match(/^(.*)[　\t]+.*$/)
                $1
            else
                title
            end
        else
            nil
        end
    end

    def match_awards_line string
        return :best_presentation_awards if string =~ /^.*Best Presentation Awards.*$/
        return :presentation_awards if string =~ /^.*Presentation Awards.*$/
        return :young_researcher_awards if string =~ /^.*Young Researcher Awards.*$/
        return nil
    end
end
