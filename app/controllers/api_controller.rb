class ApiController < ApplicationController
	include ApiHelper

	def join_game
		account_token = params[:account_token]
		response = {
			player_id: 0
		}
		api_response_with(response)
	end

	def change_location
		api_response_with({
			game_id: params[:game_id]
		})
	end

	def locations

	end

	def take_treasure
	end

end
