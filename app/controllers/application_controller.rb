class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include GrantsHelper
  include ApplicationHelper
  #include AlbumBindersHelper
  include StepsHelper
end
