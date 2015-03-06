require 'csv'
csv = CSV.open('data.csv')

unless File.file?('dailydump.txt')
  puts "Dataset unavailable. See README"
  exit
end

File.open('dailydump.txt').each_line do |line|
  begin
    parts = line.split("|")
    parts.drop(1)
    csv << parts
  rescue ArgumentError
    next
  end
end

csv.close