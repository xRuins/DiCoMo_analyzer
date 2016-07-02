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
        elsif @year <= 2008
            content = @doc.xpath('//*[@class="all"]/*[@class="main"]').text.toutf8.split("\n")
            prev_string = String.new if @year == 2007
            content.each do |td_text|
                line_type = match_awards_line(td_text)
                best_presentation_awards_begun = true if line_type == :best_presentation_awards
                break if line_type == :presentation_awards
                next unless best_presentation_awards_begun # ignore lines until the line of best presentation awards appears
                if @year == 2008
                    result = (td_text =~ /^　*[0-9A-Z-]+ (.*) .* .*$/)
                    nominated_titles << $1 if result
                elsif @year == 2007
                    if td_text =~ /^・.*$/ and !(prev_string.empty?)
                        nominated_titles << prev_string
                        prev_string = String.new
                    else
                        if prev_string.empty?
                            result = (td_text =~ /^[　 ]*[0-9A-Z-]+ (.*)$/)
                        else
                            result = (td_text =~ /^[　 ]*(.*)$/)
                        end
                        prev_string = prev_string + $1 if result
                    end
                end
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
        elsif @year <= 2008
            content = @doc.xpath('//*[@class="all"]/*[@class="main"]').text.toutf8.split("\n")
            prev_string = String.new if @year == 2007
            content.each do |td_text|
                line_type = match_awards_line(td_text)
                presentation_awards_begun = true if line_type == :presentation_awards
                break if line_type == :young_researcher_awards
                next unless presentation_awards_begun # ignore lines until the line of best presentation awards appears
                if @year == 2008
                    result = (td_text =~ /^　*[0-9A-Z-]+ (.*) .* .*$/)
                    nominated_titles << $1 if result
                elsif @year == 2007
                    if td_text =~ /^・.*$/ and !(prev_string.empty?)
                        nominated_titles << prev_string
                        prev_string = String.new
                    else
                        if prev_string.empty?
                            result = (td_text =~ /^[　 ]*[0-9A-Z-]+ (.*)$/)
                        else
                            result = (td_text =~ /^[　 ]*(.*)$/)
                        end
                        prev_string = prev_string + $1 if result
                    end
                end
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

        def get_young_researcher_awards
            nominated_titles = []
            presentation_awards_begun = false
            if @year == 2013
                @doc.xpath('//*[@id="left_content"]/div/ul/table[5]/tr/td').each do |td| #  paper award
                    td_text = td.text
                    nominated_titles << td_text if title_filter(td_text)
                end
            elsif @year >= 2014
                content = @doc.xpath('//*[@id="content"]/div/table[3]/tbody').text.toutf8.split("\n")
                content.each do |td_text|
                    nominated_titles << td_text if title_filter(td_text)
                end
            elsif @year <= 2009
                content = @doc.xpath('//*[@class="all"]/*[@class="main"]').text.toutf8.split("\n")
                prev_string = String.new if @year == 2007
                content.each do |td_text|
                    line_type = match_awards_line(td_text)
                    presentation_awards_begun = true if line_type == :young_researcher_awards
                    break if line_type == :senior_researcher_awards
                    next unless presentation_awards_begun # ignore lines until the line of best presentation awards appears
                    if @year == 2008
                        result = (td_text =~ /^　*[0-9A-Z-]+ (.*) .* .*$/)
                        nominated_titles << $1 if result
                    elsif @year == 2007
                        if td_text =~ /^・.*$/ and !(prev_string.empty?)
                            nominated_titles << prev_string
                            prev_string = String.new
                        else
                            if prev_string.empty?
                                result = (td_text =~ /^[　 ]*[0-9A-Z-]+ (.*)$/)
                            else
                                result = (td_text =~ /^[　 ]*(.*)$/)
                            end
                            prev_string = prev_string + $1 if result
                        end
                    end
                end
            else
                get_content_text.each  do |line|
                    line_type = match_awards_line(line)
                    presentation_awards_begun = true if line_type == :young_researcher_awards
                    break if line_type == :senior_researcher_awards
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
        if line.match(/^[0-9A-Z\-]+[[:space:]]+(.*)$/)
            title = $1
            if title.match(/^(.*)[　\t]+.*$/)
                $1.split(" ")[0]
            else
                title
            end
        else
            nil
        end
    end

    def match_awards_line string
        #byebug if string.include?("最優秀プレゼンテーション賞")
        if string.match(/^.*Best Presentation Awards.*$/) or string.match(/^.*最優秀プレゼンテーション.*$/)
            return :best_presentation_awards
        elsif string.match(/^.*Presentation Awards.*$/) or string.match(/^.*優秀プレゼンテーション.*$/)
            return :presentation_awards
        elsif string.match(/^.*Young Researcher Awards.*$/) or string.match(/^.*ヤングリサーチャー.*$/)
            return :young_researcher_awards
        elsif string.match(/^.*Senior Researcher Awards.*$/) or string.match(/^.*シニアリサーチャー.*$/)
            return :senior_researcher_awards
        else
            return nil
        end
    end
end
