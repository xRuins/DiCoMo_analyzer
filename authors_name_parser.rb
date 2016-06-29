module AuthorsNameParser

    def self.parse string
        name_list = []
        name = String.new
        in_parenthesis = false

        string.each_char do |c|
            case c
            when '*' then
                next  # ignore asterisk the beginning of authors' names
            when ' ','　' then # half-pitch space and full-pitch one
                spacing = true
            when '(', '（' then
                spacing = false if spacing
                in_parenthesis = true
                # ignore *(asterisk)
            when ')','）' then
                in_parenthesis = false
            when ',', '，' then # add name to list and initialize name when quoted
                name_list << name
                name = String.new
            else
                next if in_parenthesis # ignore strings between parenthesis
                if spacing
                    name << ' ' + c # add space with char to name if character appears after space
                else
                    name << c
                end
            end
        end
        name_list << name if name # add name to name_list if string ends and name presents
        return name_list
    end

end
