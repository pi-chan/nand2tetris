require 'pry-byebug'

require_relative './assembler/parser.rb'
require_relative './assembler/code.rb'

in_file = ARGV[0]
if !File.exists?(in_file) || File.ftype(in_file) != 'file' || File.extname(in_file) != '.asm'
  puts 'invalid argument'
  exit 1
end

parser = Parser.new(in_file)
code = Code.new(parser.out_file)

loop do
  parser.advance

  if parser.command_type == :A
    code.assemble_a_instruction(parser.symbol)
  elsif parser.command_type == :L
    code.assemble_l_instruction(parser.symbol)
  elsif parser.command_type == :C
    code.assemble_c_instruction(parser.comp, parser.dest, parser.jump)
  end

  break unless parser.has_more_commands?
end
