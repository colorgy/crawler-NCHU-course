require 'nokogiri'
require 'pry'
require 'json'
require 'rest-client'


courses = []
(1..1).each do |page_number|

	string = nil

	if File.exist?("1031/#{page_number}.html")
		string = File.read("1031/#{page_number}.html")
	else
		url = "https://onepiece.nchu.edu.tw/cofsys/plsql/crseqry_all?v_year=1031&v_subject=&v_text=&v_teach=&v_week=&v_mtg=&v_egroup=&v_lang=%E4%B8%AD%E6%96%87&v_crseno=&v_crseid="

		string = (RestClient.get url).to_s
		File.open("1031/#{page_number}.html", 'w') {|f| f.write(string)}
	end

end

(2..2).each do |page_number|

	string = nil

	if File.exist?("1031/#{page_number}.html")
		string = File.read("1031/#{page_number}.html")
	else
		url = "https://onepiece.nchu.edu.tw/cofsys/plsql/crseqry_all?v_year=1031&v_subject=&v_text=&v_teach=&v_week=&v_mtg=&v_egroup=&v_lang=%E8%8B%B1%E6%96%87&v_crseno=&v_crseid="

		string = (RestClient.get url).to_s
		File.open("1031/#{page_number}.html", 'w') {|f| f.write(string)}
	end

end
(3..3).each do |page_number|

	string = nil

	if File.exist?("1031/#{page_number}.html")
		string = File.read("1031/#{page_number}.html")
	else
		url = "https://onepiece.nchu.edu.tw/cofsys/plsql/crseqry_all?v_year=1032&v_subject=&v_text=&v_teach=&v_week=&v_mtg=&v_egroup=&v_lang=%E6%97%A5%E6%96%87&v_crseno=&v_crseid="

		string = (RestClient.get url).to_s
		File.open("1031/#{page_number}.html", 'w') {|f| f.write(string)}
	end

end
(4..4).each do |page_number|

	string = nil

	if File.exist?("1031/#{page_number}.html")
		string = File.read("1031/#{page_number}.html")
	else
		url = "https://onepiece.nchu.edu.tw/cofsys/plsql/crseqry_all?v_year=1032&v_subject=&v_text=&v_teach=&v_week=&v_mtg=&v_egroup=&v_lang=%E5%85%B6%E4%BB%96&v_crseno=&v_crseid="

		string = (RestClient.get url).to_s
		File.open("1031/#{page_number}.html", 'w') {|f| f.write(string)}
	end

end

