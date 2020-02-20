require 'pry-byebug'

require_relative './assembler/parser.rb'

in_file = ARGV[0]
if !File.exists?(in_file) || File.ftype(in_file) != 'file' || File.extname(in_file) != '.asm'
  puts 'invalid argument'
  exit 1
end

dir = File.dirname(in_file)
file = File.basename(in_file, '.asm')
out_file = File.join(dir, "#{file}.hack")

File.open(out_file, 'w') do |f|
  File.foreach(in_file) do |line|
    f.puts line
  end
end
