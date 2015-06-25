require 'crawler_rocks'
require 'pry'

class NchuCourseCrawler
  include CrawlerRocks::DSL

  PERIODS = {
    # Note:
    # 1st period start from 8:00 am
    # may need to change period code
    "1" => 1,
    "2" => 2,
    "3" => 3,
    "4" => 4,
    "5" => 5,
    "6" => 6,
    "7" => 7,
    "8" => 8,
    "9" => 9,
    "A" => 10,
    "B" => 11,
    "C" => 12,
    "D" => 13,
  }

  def initialize year: current_year, term: current_term, update_progress: nil, after_each: nil, params: nil

    @query_url = "https://onepiece.nchu.edu.tw/cofsys/plsql/crseqry_all"
    @base_url = "https://onepiece.nchu.edu.tw/cofsys/plsql/"

    @year = params && params["year"].to_i || year
    @term = params && params["term"].to_i || term
    @update_progress_proc = update_progress
    @after_each_proc = after_each
  end

  def courses
    visit @query_url

    langs = @doc.css('select[name="v_lang"] option:not(:first-child)').map{ |opt| opt[:value] }

    @courses = langs.map { |lang|
      r = RestClient.post @query_url, {
        v_year: "#{@year-1911}#{@term}",
        v_lang: lang
      }
      parse_courses(Nokogiri::HTML(r.to_s))
    }.inject {|arr, nxt| arr.concat(nxt)}

    @courses
  end

  def parse_courses(doc)
    dep_regex = /選課系所:(?<dep_c>.*?)\s+(?<dep_n>.*?)\s*?年級：(?<g>\d)\s+班別：(?<c>.?)\s*?/
    dep_matches = doc.css('strong').map{ |strong| strong.text.strip.gsub(/\&nbsp/, ' ') }.select{|strong| strong.match(dep_regex)}.map{|strong| strong.match(dep_regex)}

    _tables =  doc.css('table.word_13')[1..-1]
    _tables.map.with_index do |table, index|
      table.css('tr')[1..-1].map do |row|
        datas = row.css('td')
        url = "#{@base_url}#{datas[1] && datas[1].css('a')[0] && datas[1].css('a')[0][:href]}"

        # 決定是否為實習課
        normal = datas[7] && datas[7].text.gsub(/\u3000/, '').empty?

        time_index = normal ? 8 :  9
        loc_index  = normal ? 10 : 11
        lec_index  = normal ? 12 : 13

        times = datas[time_index] && datas[time_index].text
        location = datas[loc_index] && datas[loc_index].text.gsub(/\u3000/, '')

        course_days = []
        course_periods = []
        course_locations = []

        # normalize periods
        if times && location
          delim = times.include?(',') ? ',' : ' '
          times.split(' ').each do |time|
            time.match(/(?<d>\d)(?<p>.+)/) do |m|
              m[:p].split('').each do |period|
                next if PERIODS[period].nil?
                course_days << m[:d].to_i
                course_periods << PERIODS[period]
                course_locations << location.gsub(/\u3000/, '')
              end
            end
          end
        end

        # lecturer = datas[13] && datas[13].text.strip.gsub(/\u3000/, '')
        # lecturer = datas[12] && datas[12].text.strip if lecturer.empty?


        {
          year: @year,
          term: @term,
          required: datas[0] && datas[0].text,
          code: datas[1] && datas[1].text && "#{@year}-#{@term}-#{datas[1].text.strip}",
          url: url,
          name: datas[2] && datas[2].text,
          semester: datas[4] && datas[4].text,
          credits: datas[5] && datas[5].text && datas[5].text.to_i,
          hour: datas[6] && datas[6].text,
          lecturer: datas[lec_index] && datas[lec_index].text,
          # department: datas[14] && datas[14].text,
          department: dep_matches[index][:dep_n],
          department_code: dep_matches[index][:dep_c],
          note: datas[19] && datas[19].text,
          day_1: course_days[0],
          day_2: course_days[1],
          day_3: course_days[2],
          day_4: course_days[3],
          day_5: course_days[4],
          day_6: course_days[5],
          day_7: course_days[6],
          day_8: course_days[7],
          day_9: course_days[8],
          period_1: course_periods[0],
          period_2: course_periods[1],
          period_3: course_periods[2],
          period_4: course_periods[3],
          period_5: course_periods[4],
          period_6: course_periods[5],
          period_7: course_periods[6],
          period_8: course_periods[7],
          period_9: course_periods[8],
          location_1: course_locations[0],
          location_2: course_locations[1],
          location_3: course_locations[2],
          location_4: course_locations[3],
          location_5: course_locations[4],
          location_6: course_locations[5],
          location_7: course_locations[6],
          location_8: course_locations[7],
          location_9: course_locations[8],
        }
      end # table.css('tr')
    end.inject {|arr, nxt| arr.concat(nxt)} # _tables.map
  end # parse_courses

  def current_year
    (Time.now.month.between?(1, 7) ? Time.now.year - 1 : Time.now.year)
  end

  def current_term
    (Time.now.month.between?(2, 7) ? 2 : 1)
  end

end

cc = NchuCourseCrawler.new(year: 2014, term: 1)
File.write('1031_nchu_courses.json', JSON.pretty_generate(cc.courses))
