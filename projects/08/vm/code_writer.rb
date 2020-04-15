class CodeWriter
  CONSTANT = 'constant'.freeze
  STATIC = 'static'.freeze
  LOCAL = 'local'.freeze
  THIS = 'this'.freeze
  THAT = 'that'.freeze
  ARGUMENT = 'argument'.freeze
  TEMP = 'temp'.freeze
  POINTER = 'pointer'.freeze

  attr_accessor :input_file_name, :current_function_name

  def initialize(out_file)
    @file = File.open(out_file, 'w')
    write_init_code
  end

  def write_init_code
    write_code "@256",
               "D=A",
               "@SP",
               "M=D"
    write_call("Sys.init", 0)
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

  def label_name_with_function(label_name)
    "#{current_function_name}$#{label_name}"
  end

  def write_label(label_name)
    if current_function_name
      write_code "(#{label_name_with_function(label_name)})"
    else
      write_code "(#{label_name})"
    end
  end

  def write_goto(label)
    write_code "@#{label_name_with_function(label)}",
               "0;JMP"
  end

  def write_if_goto(label)
    pop_to_m_register
    write_code  "D=M",
                "@#{label_name_with_function(label)}",
                "D;JNE"
  end

  def write_function(name, arg_count)
    write_code "(#{name})",
               "D=0"

    arg_count.times do
      push_d_register
    end

    self.current_function_name = name
  end

  def write_return
    write_code "@LCL",
               "D=M",
               "@R13",
               "M=D",
               "@5",
               "D=A",
               "@R13",
               "A=M-D", # LCL - 5
               "D=M",
               "@R14",
               "M=D"

    pop_to_m_register
    write_code "D=M",
               "@ARG",
               "A=M",
               "M=D"

    write_code "@ARG",
               "D=M+1",
               "@SP",
               "M=D"

    write_code "@R13",
               "AM=M-1",
               "D=M",
               "@THAT",
               "M=D",
               "@R13",
               "AM=M-1",
               "D=M",
               "@THIS",
               "M=D",
               "@R13",
               "AM=M-1",
               "D=M",
               "@ARG",
               "M=D",
               "@R13",
               "AM=M-1",
               "D=M",
               "@LCL",
               "M=D",
               '@R14',
               'A=M',
               '0;JMP'
  end

  def write_call(name, arg_count)
    return_label = new_return_label
    write_code "// return-label",
               "@#{return_label}",
               "D=A"
    push_d_register

    write_code "@LCL", "D=M"
    push_d_register

    write_code "@ARG", "D=M"
    push_d_register

    write_code "@THIS", "D=M"
    push_d_register

    write_code "@THAT", "D=M"
    push_d_register

    write_code "@SP",
               "D=M",
               "@5",
               "D=D-A",
               "@#{arg_count}",
               "D=D-A",
               "@ARG",
               "M=D",
               "@SP",
               "D=M",
               "@LCL",
               "M=D"

    write_code "@#{name}",
               "0;JMP",
               "(#{return_label})"
  end

  def close
    @file.close
  end

  def write_code(*code_lines)
    @file.puts code_lines
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
      write_code "@5"
      index.times do
        self.write_code('A=A+1')
      end
      write_code "D=M"
      push_d_register
    when POINTER
      write_code "@3"
      index.times do
        self.write_code('A=A+1')
      end
      write_code "D=M"
      push_d_register
    when STATIC
      write_code "@#{input_file_name}.#{index}",
                 "D=M"
      push_d_register
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
                 "@5"
      index.times do
        self.write_code('A=A+1')
      end
      write_code "M=D"
    when POINTER
      pop_to_m_register
      write_code "D=M",
                 "@3"
      index.times do
        self.write_code('A=A+1')
      end
      write_code "M=D"
    when STATIC
      pop_to_m_register

      write_code "D=M",
                 "@#{input_file_name}.#{index}",
                 "M=D"
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

  def new_return_label
    @return_label_index ||= 0
    label = "_RETURN_LABEL_#{@return_label_index}"
    @return_label_index += 1
    label
  end
end
