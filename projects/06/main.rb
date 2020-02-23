require 'pry-byebug'

require_relative './assembler/parser.rb'
require_relative './assembler/code.rb'
require_relative './assembler/symbol_table.rb'

in_file = ARGV[0]
if !File.exists?(in_file) || File.ftype(in_file) != 'file' || File.extname(in_file) != '.asm'
  puts 'invalid argument'
  exit 1
end

parser = Parser.new(in_file)
code = Code.new(parser.out_file)
symbol_table = SymbolTable.new

rom_address = 0

loop do
  parser.advance

  if parser.command_type == :A
    rom_address += 1
  elsif parser.command_type == :L
    symbol_table.add_entry(parser.symbol, rom_address)
  elsif parser.command_type == :C
    rom_address += 1
  end

  break unless parser.has_more_commands?
end

parser.reset

loop do
  parser.advance

  if parser.command_type == :A
    symbol = parser.symbol
    address = if symbol_table.contains?(symbol)
                symbol_table.get_address(symbol)
              elsif symbol.match?(/\A\d+\z/)
                symbol
              else
                symbol_table.add_entry_for_new_address(symbol)
                symbol_table.get_address(symbol)
              end
    code.assemble_a_instruction(address)
  elsif parser.command_type == :L
    # do nothing
  elsif parser.command_type == :C
    code.assemble_c_instruction(parser.comp, parser.dest, parser.jump)
  end

  break unless parser.has_more_commands?
end
