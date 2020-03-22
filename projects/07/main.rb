require 'pry-byebug'

require_relative './vm/parser.rb'
require_relative './vm/code_writer.rb'
# require_relative './vm/symbol_table.rb'

parser = Parser.new(ARGV[0])
code_writer = CodeWriter.new(parser.out_file)

loop do
  parser.advance

  puts parser.current_line

  case parser.command_type
  when :C_ARITHMETIC
    code_writer.write_arithmetic(parser.arg1)
  when :C_PUSH, :C_POP
    code_writer.write_push_pop(parser.command_type, parser.arg1, parser.arg2)
  when nil
  else
    puts 'not supported'
  end

  break unless parser.has_more_commands?
end

code_writer.close
