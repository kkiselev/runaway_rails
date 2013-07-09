class Game < ActiveRecord::Base
  attr_accessible :area, 
  								:name, 
  								
  								:treasure_loc, 
  								:treasure_holder_id, 
  								:treasure_attached_at, 
  								:treasure_safe_hold_time,
  								:treasure_allowed_distance,

  								:allowed_inactivity_time

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
  			self.detach_treasure_from_player(player)
  			self.save
  		end
  	end
  end

  def attach_treasure_to_player(player)
  	self.treasure_holder_id = player.id
  	self.treasure_attached_at = Time.now
  	self.treasure_loc = nil
  	self
  end

  def detach_treasure_from_player(player)
  	if player then
  		self.treasure_loc = player.loc
  	end
		self.treasure_holder_id = nil
		self.treasure_attached_at = nil
		self
  end

  def attach_treasure_to_player_if_possible(player)
  	cur_timestamp = Time.now.to_i

		if player and player.id == self.treasure_holder_id then
			return true
		end

  	# check time
		if not self.treasure_attached_at or (self.treasure_attached_at.to_i + self.treasure_safe_hold_time < cur_timestamp) then

			#check distance
			min_distance = self.treasure_allowed_distance.to_f

			if GeoHelper.distance_less_than_value(min_distance, player.loc, self.get_treasure_loc) then
				self.attach_treasure_to_player(player)
				return true
			end
		end
		false
  end

  def to_hash
		{
			id: self.id,
			name: self.name,
			area: GeoHelper.points_array_from_polygon(self.area),
			treasure_holder_id: self.treasure_holder_id,
			treasure_attached_at: self.treasure_attached_at,
			treasure_safe_hold_time: self.treasure_safe_hold_time,
			allowed_inactivity_time: self.allowed_inactivity_time
		}
  end

  def get_treasure_loc
  	ret = nil
  	if self.treasure_holder_id then	
  		player = Player.find_by_id(self.treasure_holder_id)
  		ret = player.loc if player
  	else
  		ret = self.treasure_loc
  	end
  end

end
