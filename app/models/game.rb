class Game < ActiveRecord::Base
  attr_accessible :area, :name
  has_many :players

  self.rgeo_factory_generator = RGeo::Geos.factory_generator

  class << self
  	def current_rgeo_factory
  		RGeo::Geos.factory
  	end
  end

end
