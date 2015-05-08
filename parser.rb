require 'nokogiri'
require 'pry'
require 'json'
require 'rest-client'

courses = []
(1..4).each do |page_number|

	string = File.read("1031/#{page_number}.html")

	document = Nokogiri::HTML(string)
  base_url = "https://onepiece.nchu.edu.tw/cofsys/plsql/"

	tables =  document.css('table.word_13')[1..-1]
	tables.each do |table|
		table.css('tr')[1..-1].each do |row|
			datas = row.css('td')
      url = "#{base_url}#{datas[1] && datas[1].css('a')[0] && datas[1].css('a')[0][:href]}"
			times = datas[8] && datas[8].text
			location = datas[10] && datas[10].text

      # normalize periods
      periods = []
      if times && location
        times.split(' ').each do |time|
          m = time.match(/(?<d>\d)(?<p>\d+)/)
          if !!m
            m[:p].split('').each do |period|
              chars = []
              chars << m[:d]
              chars << period
              chars << location
              periods << chars.join(',')
            end
          end
        end
      end

      courses << {
        required: datas[0] && datas[0].text,
        code: datas[1] && datas[1].text && datas[1].text.strip,
        url: url,
        name: datas[2] && datas[2].text,
        semester: datas[4] && datas[4].text,
        periods: periods,
        credit: datas[5] && datas[5].text && datas[5].text.to_i,
        hour: datas[6] && datas[6].text,
				lecturer: datas[12] && datas[12].text,
				department: datas[14] && datas[14].text,
				note: datas[19] && datas[19].text,
			}
		end
	end
end

File.open('courses.json','w'){|file| file.write(JSON.pretty_generate(courses))}



