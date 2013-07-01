module GeoHelper

		METERS_TO_POINTS_SCALE_FACTOR = 1.473548e-5
		MIN_GRID_CELL_SIZE = METERS_TO_POINTS_SCALE_FACTOR * 1000

		MAP_GRID_SIZE = 10

		MAP_WIDTH = 180 * 2.0
		MAP_HEIGHT = 90 * 2.0
		MAP_ORIGIN_LNG = -MAP_WIDTH/2.0
		MAP_ORIGIN_LAT = -MAP_HEIGHT/2.0

		class << self
			attr_accessor	:map_sizes_

			def point_from_hash(hash)
				Game.current_rgeo_factory.point(hash[:lng].to_f, hash[:lat].to_f)
			end

			def hash_from_point(point)
				{lng: point.x, lat: point.y}
			end

			def points_array_from_polygon(polygon)
				polygon.exterior_ring.points[0..-2].map do |p|
					hash_from_point(p)
				end
			end

			def polygon_from_points_array(points_array)
				factory = Game.current_rgeo_factory
				points = []

				for i in 0..(points_array.length-1) do
					p = point_from_hash(points_array[i])
					points << p
				end
				points << points[0]

				line_string = factory.line_string(points)
				factory.polygon(line_string)
			end

			def map_sizes
				unless self.map_sizes_
					self.map_sizes_ = []
					cur_size = MAP_WIDTH / MAP_GRID_SIZE

					while cur_size > MIN_GRID_CELL_SIZE do
						self.map_sizes_ << cur_size
						cur_size /= 2.0
					end
				end
				self.map_sizes_
			end

			def grid_size_for_rect(tl_lng, tl_lat, br_lng, br_lat)
				w = (tl_lng - br_lng).abs
				h = (tl_lat - br_lat).abs
				rect_max_size = [w, h].max

				sizes = map_sizes()
				rect_max_size = [rect_max_size, sizes[0]].min
				size = nil

				for i in 0..(sizes.length-1) do
					size = sizes[i] if sizes[i] >= rect_max_size
				end
				size
			end

			def round_left_number_with_size(number, size)
				(number / size.to_f).to_i * size
			end

			def round_right_number_with_size(number, size)
				(number / size.to_f + 0.5).round * size
			end

			def normalized_rect(tl_lng, tl_lat, br_lng, br_lat)
				grid_size = grid_size_for_rect(tl_lng, tl_lat, br_lng, br_lat)
				if grid_size then
					tl_lng = round_left_number_with_size(tl_lng, grid_size) 
					tl_lat = round_right_number_with_size(tl_lat, grid_size)
					br_lng = round_right_number_with_size(br_lng, grid_size)
					br_lat = round_left_number_with_size(br_lat, grid_size)
				end
				{tl_lng: tl_lng, tl_lat: tl_lat, br_lng: br_lng, br_lat: br_lat, grid_size: grid_size}
			end

			def st_snap_to_grid(table, field, size)
				RGeo::ActiveRecord::SpatialNamedFunction.new(
					'ST_SnapToGrid',
					[table[field], (size/2.0).to_s, (size/2.0).to_s, size.to_s, size.to_s], 
					[true, true, false, false, false, false]
				)
			end

			def st_collect(attribute)
				RGeo::ActiveRecord::SpatialNamedFunction.new(
					'ST_Collect',
					[attribute],
					[true, true]
				)
			end

			def st_centroid(geom)
				RGeo::ActiveRecord::SpatialNamedFunction.new(
					'ST_Centroid',
					[geom],
					[true, true]
				)
			end
		end
end