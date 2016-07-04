require 'json'
require 'byebug'
require 'csv'
require 'kconv'
require 'moji'
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

def simplify_string string
    ret =string.dup
    #Moji::ZEN_JSYMBOL.each_char do |c|
    #chars = [" ", "・", "/", ":", "：", "", ""]
    #chars.each do |c|
    #    ret.delete(c)
    #end
    return ret
end

def search_title_from_awards title, awards
    awards.each do |year|
        begin
            year['contents'].each do |award|
                simplified_award = award.toutf8
                simplified_title = title.toutf8
                if simplified_award == simplified_title
                    return true
                end
            end
        rescue Exception => e
            puts %Q(class=[#{e.class}] message=[#{e.message}])
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
young_researcher_awards_counted = 0

presentations = read_json_file('presentations.json')
best_presentation_awards = read_json_file('best_paper_awards.json')
presentations_awards = read_json_file('paper_awards.json')
young_researcher_awards = read_json_file('young_researcher_awards.json')
presentations_with_award  = []
chairmans = []
presentations.each do |sessions|
    sessions.each do |presentation|
        # set the flag of awards
        best_presentation_nominee = search_title_from_awards(presentation['title'], best_presentation_awards)
        presentation_nominee = search_title_from_awards(presentation['title'], presentations_awards)
        young_researcher_nominee = search_title_from_awards(presentation['title'], young_researcher_awards)
        presentations_with_award << presentation.merge(best_presentation_award: best_presentation_nominee,
        presentation_award: presentation_nominee, young_researcher_award: young_researcher_nominee)
        # add new chairman to chairmans'
        chairman_name = presentation['chairman']
        chairman = chairmans.find { |c| c[:name] == chairman_name }
        # count up awards if chairman exists
        if chairman
            chairman[:number] += 1
            if best_presentation_nominee
                chairman[:best_presentation_award] += 1
                best_presentation_award_counted += 1
            elsif presentation_nominee
                chairman[:presentation_award] += 1
                presentation_award_counted += 1
            elsif young_researcher_nominee
                chairman[:young_researcher_award] += 1
                young_researcher_awards_counted += 1
            end
        else
            if best_presentation_nominee
                chairmans << {name: chairman_name, best_presentation_award: 1, presentation_award: 0, young_researcher_award: 0, number: 1}
                best_presentation_award_counted += 1
            elsif presentation_nominee
                chairmans << {name: chairman_name, best_presentation_award: 0, presentation_award: 1, young_researcher_award: 0, number: 1}
                presentation_award_counted += 1
            elsif young_researcher_nominee
                chairmans << {name: chairman_name, best_presentation_award: 0, presentation_award: 0, young_researcher_award: 1, number: 1}
                young_researcher_awards_counted += 1
            else
                chairmans << {name: chairman_name, best_presentation_award: 0, presentation_award: 0, young_researcher_award: 0, number: 1}
            end
        end
    end
end

File.open("presentations_with_award.json", "w") do |file|
    file.puts presentations_with_award.to_json.to_s
end
File.open("presentations_with_award.csv", "w") do |file|
    presentations_with_award.each do |year|
        line = year['title'] + ","
        line += year['speaker'].join('_').gsub(/_ /, '_') + ","
        line += year['session_id'] + ","
        line += year['date'] + ","
        line += year['chairman'].join(' ') + ","
        line += year[:best_presentation_award].to_s + ","
        line += year[:presentation_award].to_s + ","
        line += year[:young_researcher_award].to_s
        file.puts line
    end
end
File.open("statistic_chairman.json", "w") do |file|
    file.puts chairmans.to_json.to_s
end
File.open("statistic_chairman.csv", "w") do |file|
    chairmans.each do |chairman|
        cv = chairman.values
        name = cv[0][0]
        bp = cv[1]
        pa = cv[2]
        yr = cv[3]
        num = cv[4]
        file.puts "#{name}, #{bp}, #{pa}, #{yr}, #{num}"
    end
end

p "Best Presentation Award (actual) : #{count_number_of_awards(best_presentation_awards)}, Presentation Award (actual): #{best_presentation_award_counted}"

p "Presentation Award (actual) : #{count_number_of_awards(presentations_awards)}, Presentation Award (counted): #{presentation_award_counted}"

p "Young Researcher Award (actual) : #{count_number_of_awards(young_researcher_awards)},  Award (counted): #{young_researcher_awards_counted}"

p "BPA(remains)"
p best_presentation_awards
p "PA(remains)"
p presentations_awards
p "YR(remains)"
p young_researcher_awards
