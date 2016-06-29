require './authors_name_parser.rb'

a = '*遊佐 直樹, 澤田 尚志, 栗山 央 (静岡大), 光岡 正隆 (アドソル日進), 峰野 博史 (静岡大)'

p AuthorsNameParser.parse(a)
