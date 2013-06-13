class GameController < ApplicationController

	def show()
		@game = Game.find(params[:game_id]).first
	end

end
