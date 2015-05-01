require 'nokogiri'
require 'pry'
require 'json'
require 'rest-client'

courses = []
(1..4).each do |page_number|

	string = File.read("1031/#{page_number}.html")

	document = Nokogiri::HTML(string)

	tables =  document.css('table.word_13')[1..-1]
	tables.each do |table|
		table.css('tr')[1..-1].each do |row|
			datas = row.css('td')

			#count = 10
			courses << {
				required: datas[0] && datas[0].text,
				code_number: datas[1] && datas[1].text,
				code: datas[1] && datas[1].css('a')[0] && datas[1].css('a')[0][:href],
				name: datas[2] && datas[2].text,
				semester: datas[4] && datas[4].text,
				credit: datas[5] && datas[5].text,
				hour: datas[6] && datas[6].text,
				time: datas[8] && datas[8].text,
				classroom: datas[10] && datas[10].text,
				lecturer: datas[12] && datas[12].text,
				department: datas[14] && datas[14].text,
				note: datas[19] && datas[19].text,
			}

		end

	end
end
File.open('courses.json','w'){|file| file.write(JSON.pretty_generate(courses))}



