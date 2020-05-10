class Tokenizer
  class Token
    attr_accessor :value, :type

    def initialize(value, type)
      @value = value
      @type = type
    end
  end

  def initialize(infile, outfile)
    @infile = infile
    @outfile = outfile
  end

  def tokenize
  end
end
