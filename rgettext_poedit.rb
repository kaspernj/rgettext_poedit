#!/usr/bin/env ruby1.9.1

require "knj/autoload"

rgettext_argv = []
skipnext = false

ofn = nil

count = 0
ARGV.each do |value|
	if skipnext
		skipnext = false
	else
		skipnext = false
		
		if value == "-o"
			ofn = ARGV[count + 1]
			skipnext = true
		elsif value == "--debug"
			$debug = true
		else
			rgettext_argv << value
		end
		
		count += 1
	end
end

if !ofn
	print "No output filename defined.\n"
	exit
end

def debug(str)
	if $debug
		print str + "\n"
	end
end

find_file = "gettext/tools/rgettext.rb"
found_file = nil
$LOAD_PATH.each do |path|
	file_path = "#{path}/#{find_file}"
	if File.exists?(file_path)
		found_file = file_path
		break
	end
end

if !found_file
	#Try looking in gems-folder.
	require "rubygems"
	Knj::Php.print_r(ENV)
	Gem.path.each do |path|
		file_path = "#{path}/gems/gettext-2.1.0/bin/rgettext"
		if File.exists?(file_path)
			found_file = file_path
			break
		end
	end
	
	if !found_file
		print "Fatal error: File could not be found in $LOAD_PATH or Gem.path: #{find_file}.\n"
		exit
	end
end

rgettext_cmd = "ruby1.9.1 #{found_file} " + rgettext_argv.join(" ")
debug "Command: " + rgettext_cmd

output = %x[#{rgettext_cmd}]

debug "Output filename: " + ofn

File.open(ofn, "a") do |file|
	file.print(output)
end

debug "Output:\n" + output