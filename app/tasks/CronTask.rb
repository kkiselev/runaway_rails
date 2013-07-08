class CronTask

	class << self
		def perform(method)
			self.new.send(method)
		end
	end

	# ACTUAL CRON TASKS
	def update_tresure_holders
		Game.update_treasure_holders
	end

end