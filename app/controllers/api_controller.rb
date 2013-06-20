class ApiController < ApplicationController
	include ApiHelper
	
	def change_location
		api_response_with({:game_id => params[:id]})
	end
end
