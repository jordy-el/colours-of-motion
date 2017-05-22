# Colours of Motion

> Make a panorama of colours from a movie

This ruby script takes a movie file as an
input, processes the frames, and turns the
average colour of each into a stripe on a
panorama.

Output file is placed in same folder as input
and has the same name with '.jpg' appended.

To run, you must have ffmpeg and imagemagick.

Once those are installed, run `bundle install`
inside the project folder.

Example: `ruby app.rb ~/Desktop/Paper_Towns.mkv`
![Colours of Paper Towns](https://github.com/jordy-el/colours-of-motion/blob/master/example/Paper_Towns.mkv.jpg)

Inspired by [The Colors of Motion](http://thecolorsofmotion.com/).
