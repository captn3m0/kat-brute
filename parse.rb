# encoding: utf-8
require 'csv'
require 'nokogiri'
require 'json'

File.truncate('data.jdb', 0) if File.file?('data.jdb')

CSV.foreach("data.csv") do |row|
  title = row[0]
  torrent_url = row[3].strip
  hash = torrent_url.split('/')[4].split('.')[0]
  kat_url = row[2].strip
  category = row[1]
  html = "./html/#{hash}.html"

  next unless ["TV", "Movies"].include?(category)
  puts "#{title}\t\t#{kat_url}"

  # Download the kat info page if its not present
  unless File.file?(html) and File.size(html) > 0
    # Lets delete the file if it exists
    File.delete("#{html}.gz") if File.file?("#{html}.gz")
    `wget --tries 10 --no-check-certificate --quiet "#{kat_url}" -P "./html/" -O "#{html}.gz"`
    if File.size?("#{html}.gz")
      `gunzip "#{html}.gz"`
    else
      puts "Error in wget"
      next
    end
  end

  # We still might get blank files sometimes. Lets skip instead of trying to recover
  next unless File.size?(html)

  # Read the page
  kat_page = Nokogiri::HTML(open(html))

  # First sanity check is seeders>0
  seeders = kat_page.css('strong[itemprop=seeders]')[0].text.strip.to_i
  if seeders <= 0
    puts "S = #{seeders}"
    next
  end

  # Now we check if we have an imdb link
  imdb_id = nil
  links = kat_page.css('a')
  links.each do |link|
    url = link['href']
    if url && url.include?("imdb.com")
      imdb_id = url[/tt\d+/]
      break
    end
  end


  if imdb_id === nil
    puts "IMDB WAS NULL"
    next
  end

  # We get the episode details as well
  episode = nil
  if category == "TV"
    strongs = kat_page.css('strong')
    strongs.each do |el|
      if el.text.strip === "Episode:"
        episode = el.parent.xpath('text()').to_s.strip
      end
    end
  end

  # Finally, we need the filename
  file_divs = kat_page.css('.torFileName')
  files = []
  file_divs.each do |file|
    filename = file.text.strip
    extension = File.extname(filename)
    valid_extensions = ['.mkv', '.mp4', '.avi', '.flv', '.rmvb', '.wmv', '.mpeg', 'm4v']
    next unless valid_extensions.include? extension
    files << filename
  end

  # No point in adding if there is nothing for parser
  if files.size < 0
    puts "<0 files"
    next
  end

  data = {
    :title=> title,
    :seeds=> seeders,
    :imdb=> imdb_id,
    :kat=> kat_url,
    :files=> files
  }

  File.open('data.jdb', 'a') do |db|
    db.puts data.to_json
  end

end
