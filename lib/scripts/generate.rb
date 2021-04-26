require 'open-uri'
require 'json'
require_relative '../emoji'
require_relative '../emoji/index'

SKIP_TYPES = ["unqualified", "component", "non-fully-qualified"]

puts "Generate index.json from unicode.org"
existing = JSON.parse File.read("config/index.json")
categories = {
  "Animals & Nature" => "nature",
  "??" => "cosmos",
  "Food & Drink" => "food",
  "Activities" => "object",
  "Objects" => "object",
  "??" => "people",
  "Travel & Places" => "places",
  "Flags" => "places",
  "??" => "gesture",
  "Symbols" => "abstract",
  "??" => "tools",
  "Smileys & People" => "faces",
  "Smileys & Emotion" => "faces",
  "People & Body" => "faces",
  "??" => "transportation",
  "??" => "logos",
  "??" => "individuals"
}

group = nil
index = Emoji::Index.new(existing)

data = URI.open("https://www.unicode.org/Public/emoji/13.1/emoji-test.txt", "r:UTF-8")
data.each do |line|
  if line.start_with?("# group: ")
    group = line.gsub("# group: ", "").strip
  end
  
  next if group.nil?
  
  next unless line.include?("-qualified")

  # Parser help from: https://github.com/github/gemoji/blob/master/db/emoji-test-parser.rb
  row, desc = line.split("#", 2)
  name = desc.strip.split(" ", 2)[1]
  name = name.gsub(/E\d+\.\d /, "") # remove version info before the name
  
  if name.start_with?("keycap") || name.start_with?("flag")
    name = name.gsub(":", "")
  else
    name = name.split(":").first
  end
  codepoints, qualification = row.split(";", 2)
  next if qualification.nil? # happens near the end of the file
  next if SKIP_TYPES.include?(qualification.strip)
  moji = codepoints.strip.split.map { |c| c.hex }.pack("U*")
  emoji = nil
  
  if categories[group].nil?
    emoji = index.find_by_name(desc)
    emoji ||= index.find_by_moji(moji)
    
    if emoji
      puts "Add mapping: \"#{group}\" => \"#{emoji["category"]}\""
    else
      puts "#{name}, #{moji}"
      raise StandardError.new("No match for group: #{group} - ")
    end
  end
  
  emoji ||= index.find_by_name(name)
  emoji ||= index.find_by_moji(moji)
  
  if !emoji
    new_emoji = {
    	"moji": moji,
    	"name": name,
    	"category": categories[group] || group,
    	"unicode": codepoints.strip.split.join(" ")
    }
    puts "adding: #{new_emoji}"
    existing << new_emoji
  end

  File.write("config/index.json", "[\n" + existing.map{|line| "  #{line.to_json}"}.join(",\n") + "\n]")
end
