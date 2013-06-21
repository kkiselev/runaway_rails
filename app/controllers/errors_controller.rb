class ErrorsController < ApplicationController
	include ApiHelper
	
	def handle
		error_response_with(params[:error_code], "No description")
	end

end
