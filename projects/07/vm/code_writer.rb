class CodeWriter
  def initialize(out_file)
    @file = File.open(out_file, 'w')
  end

  def write_arithmetic(command)
    puts command
  end

  def write_push_pop(push_or_pop, segment, value)
    puts push_or_pop
  end

  def close
    @file.close
  end
end
