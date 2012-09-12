#!/usr/bin/env ruby1.9

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
	print "#{str}\n" if $debug
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
	found_file = nil
	
	Gem.path.each do |path|
    Dir.foreach("#{path}/gems") do |file|
      if match = file.match(/^gettext-.\..\..$/)
        print "File: #{file}\n"
        
        file_path = "#{path}/gems/#{file}/bin/rxgettext"
        print "Fpath: #{file_path}\n"
        
        if File.exists?(file_path)
          print "File exists: #{file_path}"
          found_file = file_path
          break
        end
      end
    end
    
    break if found_file
	end
	
	if !found_file
		print "Fatal error: File could not be found in $LOAD_PATH or Gem.path: '#{find_file}'.\n"
		exit(-1)
	end
end

rgettext_cmd = "ruby1.9.1 #{found_file} #{rgettext_argv.join(" ")}"
debug "Command: " + rgettext_cmd

add = true
output = %x[#{rgettext_cmd}]

if output.to_s.match(/Error parsing/)
  debug "Dont add because 'error-parsing': #{found_file}"
  add = false
end

debug "Output filename: " + ofn

if add
  File.open(ofn, "a") do |fp|
    fp.print(output)
  end
end

debug "Output:\n#{output}"