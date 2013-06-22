class GameController < ApplicationController

	def create
		area_points = params[:area_points]
		area_polygon = GeoHelper::polygon_from_points_array(area_points)

		@game = Game.new
		@game.name = params[:name]
		@game.area = polygon
		@game.save!

		render :action => "show"
	end

	def edit
		@game = Game.find_by_id(params[:game_id])
		unless @game
			render 'newgame.html.erb'
		else
			@area_points = GeoHelper::points_array_from_polygon(@game.area)
			render 'edit.html.erb'
		end
	end

	def show
		@game = Game.find(params[:game_id])
		render 'show.html.erb'
	end

end
