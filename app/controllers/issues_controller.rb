class IssuesController < ApplicationController
  def latest
    @issue = Issue.latest
    render :show
  end

  def show
    @issue = Issue.fetch(params[:id])
    render
  end

  def redirection
    redirect_to(issue_path(params[:id]))
  end
end
