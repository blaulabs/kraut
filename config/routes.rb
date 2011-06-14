Rails.application.routes.draw do

  resource :sessions, :controller => "kraut/sessions", :only => [:new, :create, :destroy], :as => "kraut_sessions"

end
