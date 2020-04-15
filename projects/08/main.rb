require 'pry-byebug'

require_relative './vm/parser.rb'
require_relative './vm/code_writer.rb'
# require_relative './vm/symbol_table.rb'

parser = Parser.new(ARGV[0])
code_writer = CodeWriter.new(parser.out_file)

loop do
  parser.advance

  code_writer.input_file_name = parser.current_file_name
  code_writer.write_code "// #{parser.current_line}" unless parser.command_type.nil?

  case parser.command_type
  when :C_ARITHMETIC
    code_writer.write_arithmetic(parser.arg1)
  when :C_PUSH, :C_POP
    code_writer.write_push_pop(parser.command_type, parser.arg1, parser.arg2)
  when :C_LABEL
    code_writer.write_label(parser.arg1)
  when :C_GOTO # goto
    code_writer.write_goto(parser.arg1)
  when :C_IF # if-goto
    code_writer.write_if_goto(parser.arg1)
  when :C_FUNCTION
    code_writer.write_function(parser.arg1, parser.arg2)
  when :C_RETURN
    code_writer.write_return
  when :C_CALL
    code_writer.write_call(parser.arg1, parser.arg2)
  when nil
  else
    puts 'not supported'
  end

  break unless parser.has_more_commands?
end

code_writer.close
