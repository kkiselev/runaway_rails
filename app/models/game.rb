class Game < ActiveRecord::Base
  attr_accessible :area, :name, :treasure_loc, :treasure_holder_id, :treasure_attached_at, :allowed_inactivity_time
  has_many :players

  self.rgeo_factory_generator = RGeo::Geos.factory_generator

  class << self

  	def current_rgeo_factory
  		RGeo::Geos.factory
  	end

  	def update_treasure_holders
  		games = Game.where("allowed_inactivity_time IS NOT NULL")
  		games.each do |game|
  			game.update_treasure_holders
  		end
  	end

  end

  def update_treasure_holders
  	if self.treasure_holder_id and self.allowed_inactivity_time then
  		player = Player.find_by_id(self.treasure_holder_id)
  		cur_time = Time.now

  		unless player and (cur_time.to_i - player.updated_at.to_i < self.allowed_inactivity_time)
  			self.treasure_holder_id = nil
  			self.save
  		end
  	end
  end

end
