require 'net/http'
require 'nokogiri'
require 'json'

class Issue
  BASE_DOMAIN_URL = "http://www.werewolvesfuckyoface.com"
  FILE_ROOT = 'db/issues'
  LATEST_ISSUE_ID = 11
  
  attr_reader :title, :subtitle, :next_label, :previous_label, :audio, :images, :id

  def previous_id
    if id > 2
      id + 1
    else
      LATEST_ISSUE_ID
    end
  end

  def next_id
    if id < LATEST_ISSUE_ID
      id + 1
    else
      2
    end
  end

  def self.latest
    #TODO don't hardcode this.
    self.fetch(LATEST_ISSUE_ID)
  end

  def initialize(id = nil)
    @id = id
  end

  #TODO wtf writing my own persistance enginer???
  def self.fetch(issue_number)
    issue = self.new(issue_number.to_i)
    issue.update_from_json(JSON.parse(File.read(Issue.file_name(issue_number))))
    issue
  end

  def update_from_json(json)
    @title = json['title']
    @subtitle = json['subtitle']
    @audio = Audio.from_hash(json['audio'])
    @images = json['images'].map { |image_json| Image.from_hash(image_json) }
    @next_label = json['next_label']
    @previous_label = json['previous_label']
  end

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
    url = [BASE_DOMAIN_URL, "page_#{issue_number}.html"].join('/')
    Rails.logger.debug("crawling: #{url}")
    issue = Issue.from_url(url)
    File.open(file_name(issue_number), 'w') { |file| file << issue.to_json }
  end

  def parse(html)
    doc = Nokogiri.HTML(html)
    @images = doc.css('img').map { |img| Image.from_tag(img) }
    @audio = Audio.from_tag(doc.css('embed')[0]) unless doc.css('embed').empty?
    @title = doc.css('h1').text
    @subtitle = doc.css('.soundtrack').text
    @next_label = doc.css('h3 a:contains(">")').text
    @previous_label = doc.css('h3 a:contains("<")').text
    nil
  end

  def validate
    Rails.logger.debug("missing images") if images.empty?
    Rails.logger.debug("missing audio") if audio.empty?
    Rails.logger.debug("missing title") if title.empty?
    Rails.logger.debug("missing subtitle") if subtitle.empty?
    Rails.logger.debug("missing 'next' label") if next_label.empty?
    Rails.logger.debug("missing 'prev' label") if previous_label.empty?
  end

  def to_json
    JSON.dump(as_json)
  end

  def as_json
    {
      title: title,
      subtitle: subtitle,
      next_label: next_label,
      previous_label: previous_label,
      audio: (audio and audio.as_json),
      images: images.map { |image| image.as_json }
    }
  end

end
