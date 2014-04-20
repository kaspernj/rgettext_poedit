require "knjrbfw"

class RgettextPoedit
  def initialize(args)
    @args  = args
    @files = args[:files]
    @translations = {}
    @method_names = ["_", "gettext"]
    @valid_beginning = '(^|\s+|\(|\{|<%=\s*)'
    @comments = []
  end
  
  def parse_files
    raise "No files was given." if !@files || @files.empty?
    
    @files.each do |filepath|
      parse_filepath(filepath)
    end
  end
  
  def write_file
    raise "No output-filepath was given." unless @args[:output_filepath]
    
    File.open(@args[:output_filepath], "w") do |fp|
      fp.write(generate_output)
    end
  end
  
  def generate_output
    # Generate and write output.
    @output = ""
    @translations.each do |translation, data|
      @output << "\n" if @output.length > 0
      
      data[:files].each do |file|
        @output << "#: #{file[:filepath]}:#{file[:line_no]}\n"
      end
      
      data[:comments].each do |comment|
        puts "Comment: #{comment}"
        @output << "#. #{comment}\n"
      end
      
      @output << "msgid \"#{translation}\"\n"
      @output << "msgstr \"\"\n"
    end
    
    return @output
  end
  
private
  
  # Opens a file, reads the content while keeping track of line-numbers and saves found translations.
  def parse_filepath(filepath)
    File.open(filepath, "r") do |fp|
      line_no = 0
      fp.each_line do |line|
        line_no += 1
        next if should_skip_line(filepath, line_no, line)
        parse_content(filepath, line_no, line)
      end
    end
  end
  
  # Scans content for translations and saves them.
  def parse_content(filepath, line_no, content)
    content.scan(/^\s*#\. (.+)$/) do |match|
      add_comment(match[0])
    end
    
    @method_names.each do |method_name|
      # Scan for the various valid formats.
      content.scan(/#{@valid_beginning}#{Regexp.escape(method_name)}\s*\("(.+?)"/) do |match|
        add_translation(filepath, line_no, match[1])
      end
      
      content.scan(/#{@valid_beginning}#{Regexp.escape(method_name)}\s*"(.+?)"/) do |match|
        add_translation(filepath, line_no, match[1])
      end
      
      content.scan(/#{@valid_beginning}#{Regexp.escape(method_name)}\s*\('(.+?)'/) do |match|
        add_translation(filepath, line_no, match[1])
      end
      
      content.scan(/#{@valid_beginning}#{Regexp.escape(method_name)}\s*'(.+?)'/) do |match|
        add_translation(filepath, line_no, match[1])
      end
    end
  end
  
  def should_skip_line(filepath, line_no, line)
    # Skip the line if it is a comment in Haml.
    return true if File.extname(filepath) == ".haml" && line.match(/^(\s*)-(\s*)#/)
    return false
  end
  
  def add_comment(comment)
    @comments << comment
  end
  
  def add_translation(filepath, line_no, translation)
    if !@translations.key?(translation)
      @translations[translation] = {:files => [], :comments => @comments}
    else
      @translations[translation][:comments] += @comments
    end
    
    @translations[translation][:files] << {:filepath => filepath, :line_no => line_no}
    @comments = []
  end
end
