EXCLUDE_WORDS = [
  'Mr.', 'mr.', 'mrs.', 'Mrs.', 'st.', 'St.', 'dr.', 'Dr.',
  '1.', '2.', '3.', '4.', '5.', '6.', '7.', '8.', '9.', '10.'
]

class Parser
  def self.from_txt(filename)
    File.open(filename, 'r').read
      .gsub(Regexp.union(EXCLUDE_WORDS), '')
      .gsub(/"|'/, '')
      .downcase
      .gsub(/\s+/, ' ')[1257..-2000] # This is a bit specific, to filter out Gutenberg copyright stuff
  end
end

class TextCollection
  attr_reader :sentences

  def initialize(text)
    @sentences = text.scan(/[^\.!?]+[\.!?]/).map(&:strip)
  end
end

class SimpleMarkovModel
  def initialize(sentences)
    @markov_model = Hash.new { |hash, key| hash[key] = [] }
    sentences.each do |sentence|
      tokens = tokenize(sentence)
      until tokens.empty?
        token = tokens.pop
        markov_state = [tokens[-2], tokens[-1]]
        @markov_model[markov_state] << token
      end
    end
  end

  def complete_sentence(sentence = '', min_length: 5, max_length: 20)
    tokens = tokenize(sentence)
    until sentence_complete?(tokens, min_length, max_length)
      markov_state = [tokens[-2], tokens[-1]]
      tokens << @markov_model[markov_state].sample
    end
    tokens.join(' ').strip
  end

  private

  def tokenize(sentence)
    return [] if sentence.nil? || sentence.empty?
    sentence.split(' ').map { |word| word.downcase.to_sym }
  end

  def sentence_complete?(tokens, min_length, max_length)
    tokens.length >= max_length || tokens.length >= min_length && (
      tokens.last.nil? || tokens.last =~ /[\!\?\.]\z/
    )
  end
end

text = Parser.from_txt('../data/the_adventures_of_sherlock_holmes.txt')
collection = TextCollection.new(text).sentences
model = SimpleMarkovModel.new(collection)

20.times { p model.complete_sentence }
