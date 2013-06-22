class Player < ActiveRecord::Base
  attr_accessible :loc, :name
  belongs_to :game, :account

  self.rgeo_factory_generator = RGeo::Geos.factory_generator

  class << self

		def current_rgeo_factory
			RGeo::Geos.factory
		end

		def within_box(tl_lng, tl_lat, br_lng, br_lat)
			factory = current_rgeo_factory
			tl = factory.point(tl_lng, tl_lat)
			br = factory.point(br_lng, br_lat)
			box = RGeo::Cartesian::BoundingBox.create_from_points(tl, br).to_geometry
			where("loc && ?", box)
		end

  end

end
