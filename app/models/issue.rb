require 'net/http'
require 'nokogiri'
require 'json'

class Issue
  BASE_DOMAIN_URL = "http://www.werewolvesfuckyoface.com"
  FILE_ROOT = 'db/issues'
  attr_reader :title, :subtitle, :audio, :images

  def self.from_url(url)
    issue = new
    response = Net::HTTP.get(URI(url))
    issue.parse(response)
    issue
  end

  def self.crawl_all
    (2..13).each do |issue_number|
      crawl issue_number
    end
  end

  def self.file_name(issue_number)
    File.join(FILE_ROOT, "#{issue_number}.json")
  end


  def self.crawl(issue_number)
    file_name = File.join(FILE_ROOT, "#{issue_number}.json")
    url = [BASE_DOMAIN_URL, "page_#{issue_number}.html"].join('/')
    issue = Issue.from_url(url)
    File.open(file_name(issue_number), 'w') { |file| file << issue.to_json }
  end

  def parse(html)
    doc = Nokogiri.HTML(html)
    @images = doc.css('img').map { |img| Image.from_tag(img) }
    @audio = Audio.from_tag(doc.css('embed')[0])
    @title = doc.css('h1').text
    @subtitle = doc.css('.soundtrack').text
    nil
  end

  def to_json
    JSON.dump(as_json)
  end

  def as_json
    {
      title: title,
      subtitle: subtitle,
      audio: audio,
      images: images.map { |image| image.as_json }
    }
  end

end
