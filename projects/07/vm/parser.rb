class Parser
  class NoFileError < StandardError; end
  class InvalidFileError < StandardError; end

  attr_reader :current_line

  def initialize(in_file_or_dir)
    @in_file_or_dir = in_file_or_dir
    @current_file = nil
    @files = []

    case File.ftype(in_file_or_dir)
    when 'file'
      raise InvalidFileError if File.extname(in_file_or_dir) != '.vm'
      @current_file = File.open(in_file_or_dir)
      @files = [@current_file]
    when 'directory'
      Dir.chdir(in_file_or_dir) do
        vm_files = Dir.glob("*.vm")

        raise InvalidFileError if vm_files.empty?
        vm_files.map do |file|
          @files << File.open(file)
        end
      end
      @current_file = @files.first
    end
  end

  def out_file
    dir = File.dirname(@current_file)
    file = File.basename(@current_file, '.vm')
    File.join(dir, "#{file}.asm")
  end

  def advance
    if @current_file.eof
      @current_file = next_file
    end

    return if @current_file.nil?

    @current_line = @current_file.gets.strip.strip.gsub(%r{//.+}, '').strip
  end

  def has_more_commands?
    !(last_file? && @current_file.eof)
  end

  def arg1
    tokens = @current_line.split(/\s/)

    if command_type == :C_ARITHMETIC
      tokens[0]
    else
      tokens[1]
    end
  end

  def arg2
    tokens = @current_line.split(/\s/)
    tokens[2].to_i
  end

  def command_type
    return if comment_or_empty_line?

    tokens = @current_line.split(/\s/)
    token = tokens[0]

    case token
    when 'push'
      :C_PUSH
    when 'pop'
      :C_POP
    when 'label'
      :C_LABEL
    when 'goto'
      :C_GOTO
    when 'if-goto'
      :C_IF
    when 'function'
      :C_FUNCTION
    when 'return'
      :C_RETURN
    when 'call'
      :C_CALL
    else
      :C_ARITHMETIC
    end
  end

  private

  def next_file
    next_index = @files.index(@current_file) + 1
    @files[next_index]
  end

  def last_file?
    next_file.nil?
  end

  def comment_or_empty_line?
    @current_line.start_with?('//') || @current_line.empty?
  end
end
