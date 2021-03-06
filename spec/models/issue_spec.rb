require 'spec_helper'

describe Issue do
  subject { issue }
  let(:issue) { Issue.new }
  
  describe "#parse" do
    let(:html) { File.read('spec/fixtures/html/example_issue.html') }
    before do
      issue.parse(html)
    end
    it "should count the number of images" do
      issue.images.count.should == 3
    end

    it "should populate the image src's" do
      (issue.images.map &:src ).should == [
        "images/example_1.jpeg",
        "images/example_2.jpeg",
        "images/example_3.jpeg"
      ]
    end

    context "when an audio tag is present" do
      it "should find the audio tag" do
        issue.audio.should_not be_nil
      end
      it "should parse out the audio src tag" do
        issue.audio.src.should == "_audio/CANT%20SEEM%20FOREVER.wav"
      end
    end
    
    its(:title) { should == "all necessities provided. all anxieties tranquilized. all boredom amused." }
    its(:subtitle) { should == "MOM, CLICK HERE FOR A FREE IPAD." }
    its(:next_label) { should == "want for wild things >" }
    its(:previous_label) { should == "< think wild thoughts" }

    context "with a different page" do
      let(:html) { File.read('spec/fixtures/html/example_issue_2.html') }

      its(:next_label) { should == "forgive>" }
      its(:previous_label) { should == "< hold grudge" }
    end
  end

  describe ".crawl" do
    before do
      issue_json = File.read('spec/fixtures/json/example_issue.json')
      issue_html = File.read('spec/fixtures/html/example_issue.html')
      stub_request(:get, "http://www.werewolvesfuckyoface.com/page_2.html").
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => issue_html, :headers => {})
    end
    it "should fetch a page from url, and write it's json to a file" do
      file_handle = mock
      File.should_receive(:open).with('db/issues/2.json', 'w').and_yield(file_handle)
      issue_json = "the_issue_json"
      Issue.any_instance.should_receive(:as_json).and_return(issue_json)
      file_handle.should_receive(:<<).with("\"the_issue_json\"")
      Issue.crawl(2)
    end
  end

  describe ".update_from_json" do
    it "should set all the appropriate values from json" do
      issue_json = File.read('spec/fixtures/json/example_issue.json')
      issue.update_from_json(JSON.parse(issue_json))
      issue.title.should == "latest post title"
      issue.subtitle.should == "latest post subtitle"
      issue.audio.src.should == "_audio/GOODBYE%20FOREVER.mp3"
      (issue.images.map &:src).should == [
        "_images/13/-1.jpeg",
        "_images/13/-2.jpeg",
        "_images/13/-3.jpeg"
      ]
    end
  end
end
