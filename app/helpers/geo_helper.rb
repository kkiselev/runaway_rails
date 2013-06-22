module GeoHelper

	class << self

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

	end

end