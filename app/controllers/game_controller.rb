class GameController < ApplicationController
	def create
		area_points = params[:area_points]

		factory = Game.current_rgeo_factory
		points = []

		for i in 0..(area_points.length-1) do
			p = factory.point(area_points[i][:lng].to_f, area_points[i][:lat].to_f)
			points << p
		end
		points << points[0]

		line_string = factory.line_string(points)
		polygon = factory.polygon(line_string)

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
		end
		render 'edit.html.erb'
	end

	def show
		@game = Game.find_by_id(params[:game_id])
		render 'show.html.erb'
	end

end
