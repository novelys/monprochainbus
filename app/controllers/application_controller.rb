class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :setup_main_name

protected

  def setup_main_name
    unless request.xhr?
      @main_app_name = "Bus"
      @main_app_name = "Tram" if request.subdomains(0).any?{|x| x =~ /tram/ }
    end
  end
end
