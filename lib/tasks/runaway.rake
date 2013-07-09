namespace :runaway do 
	task :update_treasure_holders => :environment do 
		Game.update_treasure_holders
	end
end