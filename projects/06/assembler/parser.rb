class Parser
  class ParseError < StandardError; end

  def initialize(in_file)
    @in_file = in_file
    @file = File.open(in_file)
  end

  def out_file
    dir = File.dirname(@in_file)
    file = File.basename(@in_file, '.asm')
    File.join(dir, "#{file}.hack")
  end

  def has_more_commands?
    !@file.eof
  end

  def advance
    @current_line = @file.gets.strip
  end

  def comment_or_empty_line?
    @current_line.start_with?('//') || @current_line.empty?
  end

  def command_type
    puts @current_line

    return if comment_or_empty_line?

    if @current_line[0] == '@'
      :A
    elsif @current_line.start_with?('(') && @current_line.end_with?(')')
      :L
    else
      :C
    end
  end

  def symbol
    case command_type
    when :A
      @current_line[1..-1]
    when :L
      @current_line[1..-2]
    else
      raise ParseError
    end
  end

  def dest
    raise ParseError if command_type != :C

    # left_operand
    lo = @current_line.split('=').first
    %w(A D M).map {|d| lo.include?(d) ? 1 : 0 }.join('')
  end

  def comp
    raise ParseError if command_type != :C

    # right_operand
    ro = @current_line.split('=').last
    a, target = if ro.include? 'M'
      ['1', 'M']
    else
      ['0', 'A']
    end

    base = case ro
           when '0'
             '101010'
           when '1'
             '111111'
           when '-1'
             '111010'
           when 'D'
             '001100'
           when target
             '110000'
           when '!D'
             '001101'
           when "!#{target}"
             '110001'
           when '-D'
             '001111'
           when "-#{target}"
             '110011'
           when 'D+1'
             '011111'
           when "#{target}+1"
             '110111'
           when 'D-1'
             '001110'
           when "#{target}-1"
             '110010'
           when "D+#{target}"
             '000010'
           when "D-#{target}"
             '010011'
           when "#{target}-D"
             '000111'
           when "D&#{target}"
             '000000'
           when "D|#{target}"
             '010101'
           end


    a + base
  end

  def jump
    raise ParseError if command_type != :C

    '000'
  end
end
