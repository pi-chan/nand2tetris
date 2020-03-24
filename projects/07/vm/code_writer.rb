class CodeWriter
  CONSTANT = 'constant'.freeze
  STATIC = 'static'.freeze
  LOCAL = 'local'.freeze
  THIS = 'this'.freeze
  THAT = 'that'.freeze
  ARGUMENT = 'argument'.freeze
  TEMP = 'temp'.freeze
  POINTER = 'pointer'.freeze

  def initialize(out_file)
    @file = File.open(out_file, 'w')
  end

  def write_arithmetic(command)
    case command
    when 'add', 'sub', 'and', 'or'
      binary_operation(command)
    when 'not', 'neg'
      unary_operation(command)
    when 'eq', 'lt', 'gt'
      compare_operation(command)
    else
      raise 'unknown'
    end
  end

  def write_push_pop(command_type, segment, index)
    if command_type == :C_PUSH
      write_push(segment, index)
    elsif command_type == :C_POP
      write_pop(segment, index)
    end
  end

  def close
    @file.close
  end

  private

  def write_push(segment, index)
    case segment
    when CONSTANT
      write_code "@#{index}", "D=A"
      push_d_register
    when LOCAL, THIS, THAT, ARGUMENT
      push_d_register_from_segment(segment, index)
    when TEMP
      write_code "@#{5+index}",
                 "D=M"
      push_d_register
    when POINTER
      register = case index
                 when 0
                   'THIS'
                 when 1
                   'THAT'
                 else
                   raise 'unknown'
                 end
      write_code "@#{register}",
                 "D=M"
      push_d_register
    when STATIC
    else
      raise 'unknown'
    end
  end

  def write_pop(segment, index)
    case segment
    when LOCAL, THIS, THAT, ARGUMENT
      pop_to_m_register_to_segment(segment, index)
    when TEMP
      pop_to_m_register
      write_code "D=M",
                 "@#{5+index}",
                 "M=D"
    when POINTER
      pop_to_m_register
      register = case index
                 when 0
                   'THIS'
                 when 1
                   'THAT'
                 else
                   raise 'unknown'
                 end
      write_code "D=M",
                 "@#{register}",
                 "M=D"
    when STATIC
    else
      raise 'unknown'
    end
  end

  def push_d_register_from_segment(segment, index)
    register = case segment
               when LOCAL
                 "LCL"
               when THIS
                 "THIS"
               when THAT
                 "THAT"
               when ARGUMENT
                 "ARG"
               end

    write_code "@#{register}", "A=M"
    index.times { write_code "A=A+1" }
    write_code "D=M"
    push_d_register
  end

  def push_d_register
    write_code "@SP",
               "A=M",
               "M=D",
               "@SP",
               "M=M+1"
  end

  def pop_to_m_register_to_segment(segment, index)
    register = case segment
               when LOCAL
                 "LCL"
               when THIS
                 "THIS"
               when THAT
                 "THAT"
               when ARGUMENT
                 "ARG"
               end

    pop_to_m_register
    write_code "D=M"

    write_code "@#{register}", "A=M"
    index.times { write_code "A=A+1" }
    write_code "M=D"
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
      write_code "D=M+D"
    when 'sub'
      write_code "D=M-D"
    when 'and'
      write_code "D=M&D"
    when 'or'
      write_code "D=M|D"
    else
      raise 'unknown'
    end
    push_d_register
  end

  def unary_operation(command)
    pop_to_m_register
    write_code "D=M"

    case command
    when 'neg'
      write_code "D=-D"
    when 'not'
      write_code "D=!D"
    else
      raise 'unknown'
    end
    push_d_register
  end

  def compare_operation(command)
    pop_to_m_register
    write_code "D=M"
    pop_to_m_register
    write_code "D=M-D"

    label1 = new_label
    label2 = new_label

    comp = case command
           when 'eq'
             "JEQ"
           when 'gt'
             "JGT"
           when 'lt'
             "JLT"
           else
             raise 'unknown'
           end

    write_code "@#{label1}",
               "D;#{comp}",
               "D=0",
               "@#{label2}",
               "0;JMP",
               "(#{label1})",
               "D=-1",
               "(#{label2})"
    push_d_register
  end

  def new_label
    @label_index ||= 0
    label = "LABEL_#{@label_index}"
    @label_index += 1
    label
  end
end
