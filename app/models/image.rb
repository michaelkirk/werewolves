class Image
  attr_reader :src
  def initialize(src)
    @src = src
  end
  def self.from_tag(doc)
    Image.new(doc[:src])
  end
end


