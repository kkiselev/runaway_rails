class GameController < ApplicationController

	def update
		area_points = params[:area_points]
		area_polygon = GeoHelper.polygon_from_points_array(area_points)

		@game = nil
		if params[:game_id] then
			@game = Game.find(params[:game_id].to_i)
		else
			@game = Game.new
		end

		@game.name = params[:name]
		@game.area = area_polygon
		@game.save!

		render :action => "show"
	end

	def edit
		@game = Game.find_by_id(params[:game_id])
		unless @game
			render 'newgame.html.erb'
		else
			render 'edit.html.erb'
		end
	end

	def show
		@game = Game.find(params[:game_id])
		render 'show.html.erb'
	end

end
