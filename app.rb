require 'streamio-ffmpeg'
require 'fileutils'
require 'mini_magick'

if !ARGV[0]
  puts "No input file specified."
  abort
end

MOVIE_PATH = ARGV[0]
OUTPUT_PATH = MOVIE_PATH.gsub("mp4", "jpg")

begin
  video = FFMPEG::Movie.new(MOVIE_PATH)
rescue SystemCallError
  puts "File does not exist."
  abort
end

print "Are you sure you want to convert '#{MOVIE_PATH}'? [y/n]: "
choice = STDIN.gets.chomp.downcase
puts "\n\n"

if choice[0] == 'y'
  begin
    video.transcode("buffer/%10d.jpg", %w(-loglevel quiet -hide_banner -vf fps=1 scale=100:-1))
    # video.transcode("buffer/%d.jpg", %w(-loglevel quiet -hide_banner -vframes 1))
  rescue
    image_buffer = Dir.glob("buffer/*")
    puts "Done creating thumbnails...\n\n"
    averages = {}
    image_buffer.each do |file|
      image = MiniMagick::Image.open(file)
      image.resize("1x1")
      average_colour = image.get_pixels.flatten
      puts "#{file}: Average done, #{average_colour}"
      averages[file] = average_colour
    end
    averages.each do |key, value|
      MiniMagick::Tool::Convert.new do |convert|
        puts "#{key}: Conversion done"
        convert << "#{key}"
        convert << "-alpha" << "off" << "-fill" << "rgb#{value}".gsub("[", "(").gsub("]", ")") << "-colorize" << "100%"
        convert << "-resize" << "1x100\!"
        convert << "#{key}"
      end
    end
    MiniMagick::Tool::Convert.new do |convert|
      convert << "+append"
      convert << "buffer/*.jpg"
      convert << "#{OUTPUT_PATH}"
    end
  end
  image_buffer.each { |file| FileUtils.rm(file) }
  puts "Done."
end
