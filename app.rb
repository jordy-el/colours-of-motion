require_relative './streamio/lib/streamio-ffmpeg.rb'
require 'fileutils'
require 'mini_magick'
require 'ruby-progressbar'

if !ARGV[0]
  puts "No input file specified."
  abort
end

MOVIE_PATH = ARGV[0]
OUTPUT_PATH = "#{MOVIE_PATH}.jpg"

begin
  video = FFMPEG::Movie.new(MOVIE_PATH)
rescue SystemCallError
  puts "\nFile does not exist."
  abort
end

print "\nAre you sure you want to convert '#{MOVIE_PATH}'? [y/n]: "
choice = STDIN.gets.chomp.downcase
puts "\n"

if choice[0] == 'y'
  #
  # Should turn mp4 into separate keyframes and store them in a buffer
  video_progress_bar = ProgressBar.create(format: "%t: |%B| %P%%", title: "Processing video", total: 100)
  video.transcode("buffer/%10d.jpg", %w(-vf select='eq(pict_type\,I)' -vsync vfr), validate: false) do |progress|
    video_progress_bar.progress =  (progress * 100)
  end
  image_buffer = Dir.glob("buffer/*")

  #
  # Should resize picture to single pixel of average colour in frame
  average_progress_bar = ProgressBar.create(format: "%t: |%B| %P%%", title: "Getting averages", total: image_buffer.length)
  image_buffer.each do |file|
    MiniMagick::Tool::Convert.new do |convert|
      convert << file
      convert << "-resize" << "1x1!"
      convert << file
    end
    average_progress_bar.increment
  end

  #
  # Should stitch all of the frames together, then resize
  MiniMagick::Tool::Convert.new do |convert|
    convert << "+append"
    convert << "buffer/*.jpg"
    convert << "#{OUTPUT_PATH}"
  end
  MiniMagick::Tool::Convert.new do |convert|
    convert << "#{OUTPUT_PATH}"
    convert << "-scale" << "3240x1080!"
    convert << "#{OUTPUT_PATH}"
  end

  #
  # Should empty image buffer
  image_buffer.each { |file| FileUtils.rm(file) }
  puts "\nDone.\n\n"
end
