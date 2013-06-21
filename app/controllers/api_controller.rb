class ApiController < ApplicationController
	include ApiHelper

	def change_location
		player_id = params[:player_id]
		api_response_with({:game_id => params[:id]})
	end

	def locations
		
	end

	def take_treasure
	end

end
