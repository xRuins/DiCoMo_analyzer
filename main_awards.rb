require 'json'
require 'byebug'
require './award_scraper.rb'
require './scraper.rb'

target_year = (2010..2015)


best_paper_awards = []
paper_awards = []

for year in target_year do
    p "proceeding #{year}..."
    if year >= 2014
        url = "http://www.dicomo.org/#{year}/#{year}/commendation/index.html"
    else
        url = "http://dicomo.org/#{year}/commendation.html"
    end
    p " #{url}"
    begin
        scraper = AwardsScraper.new(url, year)
    rescue InvalidPageException
        break
    end
    best_paper_awards << {year: year, contents: scraper.get_best_presentation_awards}
    paper_awards << {year: year, contents: scraper.get_presentation_awards}
end
p best_paper_awards
p "-----------------------"
p paper_awards

File.open('best_paper_awards.json', 'w') do |file|
    file.puts best_paper_awards.to_json.to_s
end
File.open('paper_awards.json',  'w') do |file|
    file.puts paper_awards.to_json.to_s
end
