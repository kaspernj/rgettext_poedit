#!/usr/bin/env ruby1.9.1

require "knj/autoload"
include Knj::Php

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
	die "No output filename defined.\n"
end

def debug(str)
	if $debug
		print str + "\n"
	end
end

Knj::Php.print_r(ENV)
exit

rgettext_cmd = "ruby1.9.1 /usr/lib/ruby/1.9.1/gettext/tools/rgettext.rb " + rgettext_argv.join(" ")
debug "Command: " + rgettext_cmd

output = %x[#{rgettext_cmd}]

debug "Output filename: " + ofn

File.open(ofn, "a") do |file|
	file.print(output)
end

debug "Output:\n" + output