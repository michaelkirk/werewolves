class IssuesController < ApplicationController
  def latest
    issue_json = File.read('db/issues/latest.json')
    @issue_hash = HashWithIndifferentAccess.new(JSON.parse(issue_json))
    render :show
  end

  def show
    file = sprintf('db/issues/%d.json', params[:id])
    issue_json = File.read(file)
    @issue_hash = HashWithIndifferentAccess.new(JSON.parse(issue_json))
    render
  end
end
