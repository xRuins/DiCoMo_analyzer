require 'json'
require 'byebug'
require 'csv'
require 'kconv'
require './schedule_scraper.rb'
require './scraper.rb'

def read_json_file path
    read_file = String.new
    begin
        File.open(path) do |file|
            file.read.split("\n").each do |line|
                read_file.concat(line)
            end
        end
    rescue SystemCallError => e
        puts %Q(class=[#{e.class}] message=[#{e.message}])
    rescue IOError => e
        puts %Q(class=[#{e.class}] message=[#{e.message}])
    end
    return JSON.parse(read_file)
end

def search_title_from_awards title, awards
    awards.each do |year|
        begin
            year['contents'].each do |award|
                return true if award.toutf8 == title.toutf8
            end
        rescue Exception => e
            puts %Q(class=[#{e.class}] message=[#{e.message}])
            #byebug
        end
    end
    return false
end

def count_number_of_awards awards
    number = 0
    awards.each do |year|
        year['contents'].each do |award|
            number += 1
        end
    end
    return number
end

best_presentation_award_counted = 0
presentation_award_counted = 0

presentations = read_json_file('presentations.json')
best_presentation_awards = read_json_file('best_paper_awards.json')
presentations_awards = read_json_file('paper_awards.json')

presentations_with_award  = []
chairmans = []
presentations.each do |sessions|
    sessions.each do |presentation|
        # set the flag of awards
        best_presentation_nominee = search_title_from_awards(presentation['title'], best_presentation_awards)
        presentation_nominee = search_title_from_awards(presentation['title'], presentations_awards)
        presentations_with_award << presentation.merge(best_presentation_award: best_presentation_nominee,
        presentation_award: presentation_nominee)
        # add new chairman to chairmans'
        chairman_name = presentation['chairman']
        chairman = chairmans.find { |c| c[:name] == chairman_name }
        # count up awards if chairman exists
        if chairman
            if best_presentation_nominee
                chairman[:best_presentation_award] += 1
                best_presentation_award_counted += 1
            end
            if presentation_nominee
                chairman[:presentation_award] += 1
                presentation_award_counted += 1
            end
        else
            chairmans << {name: chairman_name, best_presentation_award: 0, presentation_award: 0}
        end
    end
end

File.open("presentations_with_award.json", "w") do |file|
    file.puts presentations_with_award.to_json.to_s
end
File.open("statistic_chairman.json", "w") do |file|
    file.puts chairmans.to_json.to_s
end
File.open("statistic_chairman.csv", "w") do |file|
    chairmans.each do |chairman|
        file.puts chairman.values.to_csv
    end
end

p "Best Presentation Award (actual) : #{count_number_of_awards(best_presentation_awards)}, Presentation Award (actual): #{count_number_of_awards(presentations_awards)}"

p "Best Presentation Award (counted) : #{best_presentation_award_counted}, Presentation Award (counted): #{presentation_award_counted}"
