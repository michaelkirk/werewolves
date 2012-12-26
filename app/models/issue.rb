require 'net/http'
require 'nokogiri'

class Issue
  attr_reader :images

  def self.from_url(url)
    issue = new
    response = Net::HTTP.get(url)
    issue.parse(response)
    issue
  end

  def parse(html)
    doc = Nokogiri.HTML(html)
    @images = doc.css('img').map { |img| Image.from_tag(img) }
    nil
  end
end
