class Code
  def initialize(out_file)
    @file = File.open(out_file, 'w')
  end

  def assemble_a_instruction(symbol)
    @file.puts "0%015b" % symbol
  end

  def assemble_c_instruction(comp, dest, jump)
    @file.puts "111#{comp}#{dest}#{jump}"
  end

  def close
    @file.close
  end
end
