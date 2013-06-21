class Game < ActiveRecord::Base
  attr_accessible :area, :name
  has_many :players

  class << self
  	def current_rgeo_factory
  		RGeo::Geos.factory
  	end
  end

  self.rgeo_factory_generator = RGeo::Geos.factory_generator
end
