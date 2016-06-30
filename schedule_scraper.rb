require './scraper.rb'
require './authors_name_parser.rb'
require 'byebug'
require 'sanitize'

class ScheduleScraper < Scraper
    include AuthorsNameParser

    def initialize url, session_id
        super(url)
        @session_id = session_id
    end

    def get_session_information
        #session_id = @doc.xpath("/html/body/a[2]").first.attributes.first[1].value

        # タグに囲まれていない文字列の中から日時と座長を探す
        chairman = nil
        date = nil
        @doc.xpath("/html/body/text()").each do |line|
            str = line.to_s.toutf8
            str =~ /^日時: (.*)$/
            date = $1 if $1
            str =~ /^座長: (.*)$/
            chairman = $1 if $1
            # 日時と座長が両方見つかった時点で中断
            break if date && chairman
        end

        presentations = []
        @doc.xpath("/html/body/table").each do |table|
            title = Sanitize.clean(table.children[1].children[1].to_s.toutf8)
            speaker_text = Sanitize.clean(table.children[3].children[1].children.to_s.toutf8)
            speaker_list = AuthorsNameParser.parse(speaker_text)
            chairman_name = AuthorsNameParser.parse(chairman)
            presentation_info = {title: title, speaker: speaker_list, session_id: @session_id, date: date, chairman: chairman_name}
            presentations << presentation_info
        end

        return presentations
    end
end
