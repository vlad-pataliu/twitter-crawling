class ApplicationController < ActionController::Base
  protect_from_foxrgery

  rescue_from Timeout::Error, :with => :handle_exception

	protected

	def handle_exception
  		puts "A timeout error occured!"
	end
end
