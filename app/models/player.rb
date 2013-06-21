class Player < ActiveRecord::Base
  attr_accessible :loc, :name
  belongs_to :game, :account

	# By default, use the GEOS implementation for spatial columns.
  self.rgeo_factory_generator = RGeo::Geos.factory_generator
end
