require 'spec_helper'

describe Issue do
  describe "#parse" do
    it "should count the number of images" do
      issue = Issue.new
      html = File.read('spec/fixtures/html/example_issue.html')
      issue.parse(html)
      issue.images.count.should == 3
      (issue.images.map &:src ).should == [
        "images/example_1.jpeg",
        "images/example_2.jpeg",
        "images/example_3.jpeg"
      ]
    end
  end
end
