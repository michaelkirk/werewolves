class IssuesController < ApplicationController
  def latest
    issue_json = File.read('db/issues/latest.json')
    @issue_hash = HashWithIndifferentAccess.new(JSON.parse(issue_json))
    render :show
  end
end
