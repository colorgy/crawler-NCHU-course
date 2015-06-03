require 'crawler_rocks'
require 'pry'

class NchuCourseCrawler
  include CrawlerRocks::DSL

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

    File.write('courses.json', JSON.pretty_generate(@courses))
    @courses
  end

  def parse_courses(doc)
    _tables =  doc.css('table.word_13')[1..-1]
    _tables.map do |table|
      table.css('tr')[1..-1].map do |row|
        datas = row.css('td')
        url = "#{@base_url}#{datas[1] && datas[1].css('a')[0] && datas[1].css('a')[0][:href]}"

        times = datas[8] && datas[8].text
        location = datas[10] && datas[10].text

        course_days = []
        course_periods = []
        course_locations = []
        # normalize periods
        if times && location
          times.split(' ').each do |time|
            time.match(/(?<d>\d)(?<p>\d+)/) do |m|
              m[:p].split('').each do |period|
                course_days << m[:d]
                course_periods << period
                course_locations << location
              end
            end
          end
        end

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
          lecturer: datas[12] && datas[12].text,
          department: datas[14] && datas[14].text,
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
cc.courses
