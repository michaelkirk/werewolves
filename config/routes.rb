Werewolves::Application.routes.draw do
  get "page_:id.html" => 'issues#redirection'
  get "index.html" => 'issues#redirection', :id => Issue::LATEST_ISSUE_ID
  get "issues/:id" => 'issues#show', :as => 'issue'
  root :to => 'issues#latest'
end
