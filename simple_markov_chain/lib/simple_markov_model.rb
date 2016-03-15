EXCLUDE_WORDS = [
  '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
  '{', '}', '*', '<', '>', '-', '_', '(', ')', '+', '[', ']', '='
]

class Parser
  def self.from_txt(*filenames)
    combined_text = filenames.reduce('') do |text, filename|
      text + File.open(filename, 'r').read
    end
    combined_text
      .downcase
      .gsub(Regexp.union(EXCLUDE_WORDS), ' ')
      .gsub(/"|'/, '')
      .gsub(/\s+/, ' ')
  end
end

class TextCollection
  attr_reader :sentences

  def initialize(text)
    @sentences = text.scan(/[^\.!?]+[\.!?]/)
  end
end

class SimpleMarkovModel
  def initialize(sentences)
    @markov_model = Hash.new { |hash, key| hash[key] = [] }
    sentences.each do |sentence|
      tokens = tokenize(sentence)
      until tokens.empty?
        token = tokens.pop
        # markov_state = [tokens[-5], tokens[-4], tokens[-3], tokens[-2], tokens[-1]] # Can use longer state chains
        markov_state = [tokens[-3], tokens[-2], tokens[-1]]
        @markov_model[markov_state] << token
      end
    end
  end

  def complete_sentence(sentence = '', min_length: 5, max_length: 20)
    tokens = tokenize(sentence)
    until sentence_complete?(tokens, min_length, max_length)
      # markov_state = [tokens[-5], tokens[-4], tokens[-3], tokens[-2], tokens[-1]] # Can use longer state chains
      markov_state = [tokens[-3], tokens[-2], tokens[-1]]
      tokens << @markov_model[markov_state].sample
    end
    tokens.join(' ')
  end

  private

  def tokenize(sentence)
    return [] if sentence.nil? || sentence.empty?
    sentence.split(' ').map { |word| word.downcase.to_sym }
  end

  def sentence_complete?(tokens, min_length, max_length)
    tokens.length >= max_length || tokens.length >= min_length && (
      tokens.last =~ /[\!\?\.]\z/
    )
  end
end

text = Parser.from_txt(
  '../data/the_adventures_of_sherlock_holmes.txt',
  # '../data/the_dunwich_horror.txt',
  # '../data/the_faerie_queene.txt',
  '../data/frankenstein.txt',
  # '../data/a_princess_of_mars.txt',
  # '../data/morte_darthur.txt'
  # '../data/the_canterbury_tales.txt',
)
collection = TextCollection.new(text).sentences
model = SimpleMarkovModel.new(collection)

# 5.times { puts "Title: #{model.complete_sentence('a', min_length: 0, max_length: 10).split(/\.|\?|;|,|:/)[0].capitalize}" }

5.times { print model.complete_sentence + ' ' }
print '...'
