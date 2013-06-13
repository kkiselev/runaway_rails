class PlayerController < ApplicationController

	def show()
		@player = Player.find(params[:player_id]).first
	end

end
