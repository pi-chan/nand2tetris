class SymbolTable
  DEFINED_SYMBOLS = {
    'SP' => 0,
    'LCL' => 1,
    'ARG' => 2,
    'THIS' => 3,
    'THAT' => 4,
    'R0' => 0,
    'R1' => 1,
    'R2' => 2,
    'R3' => 3,
    'R4' => 4,
    'R5' => 5,
    'R6' => 6,
    'R7' => 7,
    'R8' => 8,
    'R9' => 9,
    'R10' => 10,
    'R11' => 11,
    'R12' => 12,
    'R13' => 13,
    'R14' => 14,
    'R15' => 15,
    'SCREEN' => 16384,
    'KBD' => 24576,
  }.freeze

  attr_reader :table

  def initialize
    @table = DEFINED_SYMBOLS.dup
    @minimum_address_pointer = 16
  end

  def add_entry(symbol_str, address)
    @table[symbol_str] = address
  end

  def add_entry_for_new_address(symbol_str)
    @table[symbol_str] = @minimum_address_pointer
    @minimum_address_pointer += 1
  end

  def contains?(symbol_str)
    @table.key?(symbol_str)
  end

  def get_address(symbol_str)
    @table[symbol_str]
  end
end
