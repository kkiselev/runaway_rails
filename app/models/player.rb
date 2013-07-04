class Player < ActiveRecord::Base
  attr_accessible :loc, :name
  belongs_to :game
  belongs_to :account

  self.rgeo_factory_generator = RGeo::Geos.factory_generator

  class << self

		def current_rgeo_factory
			RGeo::Geos.factory
		end

		def within_box(tl_lng, tl_lat, br_lng, br_lat)
			factory = current_rgeo_factory
			tl = factory.point(tl_lng, tl_lat)
			br = factory.point(br_lng, br_lat)
			box = RGeo::Cartesian::BoundingBox.create_from_points(tl, br)
			where("loc && ?", box)
		end

		def by_token(token) 
			player_id = token.to_i
			Player.find_by_id(player_id)
		end

		def create_static_bots_and_delete_old(num, game, groups_num)
			Random.srand(113)

			group_points = []
			
			min_x = min_y = 100000
			max_x = max_y = -100000

			area_points = GeoHelper.points_array_from_polygon(game.area)
			area_points.each do |p|
				min_x = p[:lng] if min_x > p[:lng]
				min_y = p[:lat] if min_y > p[:lat]
				max_x = p[:lng] if max_x < p[:lng]
				max_y = p[:lat] if max_y < p[:lat] 
			end

			for i in 0..groups_num-1 do
				x = min_x + 0.5 * (max_x - min_x) * (Random.rand() + 0.5)
				y = min_y + 0.5 * (max_y - min_y) * (Random.rand(1000000)/1000000.0 + 0.5)
				group_points << {lng: x, lat: y}
			end

			existed_bots = Player.where("game_id = :game_id AND account_id IS NULL", :game_id => game.id)
			existed_bots.destroy_all

			bots = []
			for i in 0..(num - 1) do 
				group_index = Random.rand(group_points.length)
				gx = group_points[group_index][:lng]
				gy = group_points[group_index][:lat]

				gspread = [(max_x - min_x), (max_y - min_y)].min.to_f / [15, groups_num].min.to_f / 2.0
				x = gx + gspread * (Random.rand() - 1.0)
				y = gy + gspread * (Random.rand() - 1.0)

				player = Player.new
				player.game = game
				player.loc = GeoHelper.point_from_hash({lng: x, lat: y})
				player.save

				bots << player
			end
			bots
		end

  end

end
