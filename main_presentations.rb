require 'json'
require 'byebug'
require 'csv'
require './schedule_scraper.rb'
require './scraper.rb'

target_year = (2007..2015)


scraped_info = []
for year in target_year do
    p "proceeding for the program of #{year}..."
    num = 1
    alphabet = 'A'
    fail_alphabet = false

    # roop of number of sessions
    while true
        session_id = "#{num}#{alphabet}"
        url = "http://www.dicomo.org/#{year}/program/#{session_id}.html" if year != 2015
        url = "http://tsys.jp/dicomo/2015/program/#{session_id}.html" if year == 2015
        p "#{session_id} , #{url}"
        begin
            scraper = ScheduleScraper.new(url, session_id)
        rescue InvalidPageException
            # アルファベットでfail + 数字でもfailなら終了
            if fail_alphabet
                break
                # 直前にアルファベットでfailしていないなら数字を上げ，アルファベットをリセット
            else
                fail_alphabet = true
                num += 1
                alphabet = 'A'
                next
            end
        end
        scraped_info << scraper.get_session_information
        alphabet.succ!
        fail_alphabet = false
    end
end

#p scraped_info.to_json
File.open("presentations.json", "w") do |file|
    file.puts scraped_info.to_json.to_s
end
File.open("presentations.csv","w") do |file|
    file.puts scraped_info.to_csv.to_s
end
