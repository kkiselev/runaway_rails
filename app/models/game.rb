class Game < ActiveRecord::Base
  attr_accessible :area, :name

	# By default, use the GEOS implementation for spatial columns.
  self.rgeo_factory_generator = RGeo::Geos.factory_generator
end
