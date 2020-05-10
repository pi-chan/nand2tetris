require 'pry-byebug'
require_relative './tokenizer.rb'

class NoFileError < StandardError; end
class InvalidFileError < StandardError; end

file_or_dir = ARGV[0]
files = []
case File.ftype(file_or_dir)
when 'file'
  raise InvalidFileError if File.extname(file_or_dir) != '.jack'
  files << File.join(Dir.pwd, file_or_dir)
when 'directory'
  Dir.chdir(file_or_dir) do
    jack_files = Dir.glob('*.jack')
    raise InvalidFileError if jack_files.empty?
    jack_files.map do |file|
      files << File.join(Dir.pwd, file)
    end
  end
end

files.each do |file|
  out_file = file.sub(/\.jack\z/, '_tokens.xml')
  tokenizer = Tokenizer.new(file, outfile)
  tokenizer.tokenize
end
