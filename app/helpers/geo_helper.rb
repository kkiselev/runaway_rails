module GeoHelper

		METERS_TO_POINTS_SCALE_FACTOR = 1.473548e-5
		MIN_GRID_CELL_SIZE = METERS_TO_POINTS_SCALE_FACTOR * 100

		MAP_GRID_SIZE = 50

		MAP_WIDTH = 180 * 2.0
		MAP_HEIGHT = 90 * 2.0
		MAP_ORIGIN_LNG = -MAP_WIDTH/2.0
		MAP_ORIGIN_LAT = -MAP_HEIGHT/2.0

		class << self
			attr_accessor	:map_sizes_

			def distance_less_than_value(value, p1, p2)
				v = value * METERS_TO_POINTS_SCALE_FACTOR
				v2 = v * v
				d2 = self.point_distance_2(p1, p2)
				d2 < v2
			end

			def point_distance_2(point1, point2)
				p1 = self.hash_from_point(point1)
				p2 = self.hash_from_point(point2)
				self.loc_distance_2(p1, p2)
			end

			def loc_distance_2(loc1, loc2)
				self.distance_2(
					loc1[:lng].to_f,
					loc1[:lat].to_f,
					loc2[:lng].to_f,
					loc2[:lat].to_f
				)
			end

			def distance_2(x1, y1, x2, y2)
				(x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)
			end

			def point_from_hash(hash)
				unless hash
					nil
				else 
					Game.current_rgeo_factory.point(hash[:lng].to_f, hash[:lat].to_f)
				end
			end

			def hash_from_point(point)
				unless point
					nil
				else
					{lng: point.x, lat: point.y}
				end
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
					size = sizes[i] if sizes[i] >= rect_max_size/20.0
				end
				# puts "\n\n\nSIZES:\n#{sizes}\n\nGRID SIZE: #{size}\n\n\n\n"
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
					tl_lng = [-MAP_WIDTH/2.0, round_left_number_with_size(tl_lng, grid_size) - grid_size].max
					tl_lat = [MAP_HEIGHT/2.0, round_right_number_with_size(tl_lat, grid_size) + grid_size].min
					br_lng = [MAP_WIDTH/2.0, round_right_number_with_size(br_lng, grid_size) + grid_size].min
					br_lat = [-MAP_HEIGHT/2.0, round_left_number_with_size(br_lat, grid_size) - grid_size].max
				end
				{tl_lng: tl_lng, tl_lat: tl_lat, br_lng: br_lng, br_lat: br_lat, grid_size: grid_size}
			end

			def cell_index(point, grid_size)
				row = (point.y / grid_size.to_f).to_i
				col = (point.x / grid_size.to_f).to_i
				cols_num = (MAP_WIDTH / grid_size.to_f).to_i
				row * cols_num + col
			end
			
			def cell_point(index, grid_size)
				cols_num = (MAP_WIDTH / grid_size.to_f).to_i
				row = index/cols_num
				col = index%cols_num
				point_from_hash({lng: (col * grid_size), lat: (row * grid_size)})
			end

			def st_snap_to_grid(table, field, size)
				RGeo::ActiveRecord::SpatialNamedFunction.new(
					'ST_SnapToGrid',
					[table[field], 0.to_s, 0.to_s, size.to_s, size.to_s], 
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