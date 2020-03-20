class CodeWriter
  CONSTANT = 'constant'.freeze

  def initialize(out_file)
    @file = File.open(out_file, 'w')
  end

  def write_arithmetic(command)
    case command
    when 'add', 'sub', 'and', 'or'
      binary_operation(command)
    else
      raise 'unknown'
    end
  end

  def write_push_pop(command_type, segment, index)
    if segment == CONSTANT
      write_code "@#{index}", "D=A"
      push_d_register
    else
      raise 'unknown'
    end
  end

  def close
    @file.close
  end

  private

  def push_d_register
    write_code "@SP",
               "A=M",
               "M=D",
               "@SP",
               "M=M+1"
  end

  def pop_to_m_register
    write_code "@SP",
               "M=M-1",
               "A=M"
  end

  def write_code(*code_lines)
    @file.puts code_lines
  end

  def binary_operation(command)
    pop_to_m_register
    write_code "D=M"
    pop_to_m_register

    case command
    when 'add'
      write_code "D=D+M"
    when 'sub'
      write_code "D=D-M"
    when 'and'
      write_code "D=D&M"
    when 'or'
      write_code "D=D|M"
    else
      raise 'unknown'
    end
    push_d_register
  end
end
