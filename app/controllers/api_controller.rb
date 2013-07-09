class ApiController < ApplicationController
	include ApiHelper

	# /register
	#
	# POST
	# 	:login
	#  	:password
	# 	:last_name
	# 	:first_name
	#
	def register
		safe -> {
			account = Account.where("login = :login", :login => params[:login]).first
			unless account
				account = Account.new
				account.login = params[:login]
				account.password = params[:password]
				account.last_name = params[:last_name]
				account.first_name = params[:first_name]
				account.save!

				api_response_with(200, 
					dict_with_account_and_token(account, account.id)
				)
			else
				error_response_with(403, "Account already exists")
			end
		}
	end

	# /auth
	#
	# POST
	# 	:login
	#  	:password
	#
	def auth
		safe -> {
			login = params[:login]
			pass = params[:password]

			account = Account.where("login = :login AND password = :password", {login: params[:login], password: params[:password]}).first
			unless account 
				error_response_with(401, "Authorization failed")
			else 
				api_response_with(200, 
					dict_with_account_and_token(account, account.id)
				)
			end
		}
	end

	# /games_list
	#
	# GET
	# 	:account_token
	#
	def games_list
		safe -> {
			account = Account.by_token(params[:account_token])
			unless account
				error_response_with(401, "Unathorized")
			else 
				games = Game.order("created_at DESC")
				list = []
				for i in 0..(games.length-1) do 
					game = games[i].to_hash
					list << game
				end

				api_response_with(200, {
					games: list
				})
			end
		}
	end

	# /game/:game_id/join
	#
	# POST
	# 	:account_token
	#
	def join_game
		safe -> {
			account = Account.by_token(params[:account_token])
			unless account
				error_response_with(401, "Unathorized")
			else 
				game = Game.find_by_id(params[:game_id].to_i)
				unless game
					error_response_with(404, "Game not found")
				else 
					player = Player.where("account_id = :account_id AND game_id = :game_id", {account_id: account.id, game_id: game.id}).first
					unless player
						player = Player.new
						player.game = game
						player.account = account
						player.save!
					end
					api_response_with(200, dict_with_player_and_token(player, player.id))
				end	
			end
		}
	end

	# /game/:game_id/change_location
	#
	# POST
	# 	:player_token
	#  	:lng
	#  	:lat
	#
	# Response: 
	#  	{ "ok" : 1 }
	#
	def change_location
		safe -> {
			player = Player.by_token(params[:player_token])
			game = Game.find_by_id(params[:game_id])

			unless player and game
				error_response_with(401, "Unathorized")
			else
				unless params[:lng] and params[:lat]
					error_response_with(400, "Longitude and latitude are not specified")
				else
					loc = GeoHelper.point_from_hash({lng: params[:lng], lat: params[:lat]})
					
					if loc.within?(game.area) then
						player.loc = loc
						player.save!
						api_response_with(200, {ok: true})
					else
						error_response_with(403, "Location is not in the game area")
					end
				end
			end
		}
	end

	# /game/:game_id/locations
	#
	# GET
	# 	:player_token
	#  	:region[topleft_lng]
	#  	:region[topleft_lng]
	#  	:region[bottomright_lng]
	#  	:region[bottomright_lat]
	#
	# Response: 
	#  	{ 
	#      "objects" : [
	#          ...
	#          {
	#              "id": 1,
	#              "loc": { "lng" : 37.6767, "lat" : 55.89898 },
	#              "type": "player"|"group"|"treasure"
	#          }
	#          ...
	#      ]
	#   }
	#
	def locations
		safe -> {
			player = Player.by_token(params[:player_token])
			game = Game.find_by_id(params[:game_id])

			unless player and game
				error_response_with(401, "Unathorized")
			else
				tl_lng = params[:region][:topleft_lng].to_f
				tl_lat = params[:region][:topleft_lat].to_f
				br_lng = params[:region][:bottomright_lng].to_f
				br_lat = params[:region][:bottomright_lat].to_f
			
				unless tl_lng and tl_lat and br_lng and br_lat 
					error_response_with(400, "Region is not specified")
				else
					players = Player.where("game_id = :game_id", :game_id => game.id)

					bbox = GeoHelper.normalized_rect(tl_lng, tl_lat, br_lng, br_lat)
					players = players.within_box(bbox[:tl_lng], bbox[:tl_lat], bbox[:br_lng], bbox[:br_lat])

					arel_table = Player.arel_table
					loc_attr = arel_table[:loc]

					grid_size = bbox[:grid_size]
					
					cluster_size_attr_name = "num"
					id_attr_name = "id"
					loc_attr_name = "loc"

					# if (grid_size) then
					# 	players = players.select("MIN(#{id_attr_name}) AS #{id_attr_name}")

					# 	# add number of objects
					# 	players = players.select(loc_attr.count().as(cluster_size_attr_name))

					# 	# add centroid of cluster
					# 	players = players.select(GeoHelper.st_centroid(GeoHelper.st_collect(loc_attr)).as(loc_attr_name))

					# 	snap_to_grid = GeoHelper.st_snap_to_grid(Player.arel_table, :loc, grid_size)
					# 	players = players.group(snap_to_grid)
					# else 
						players = players.select("1 AS #{cluster_size_attr_name}")
						players = players.select("#{id_attr_name}")
						players = players.select("#{loc_attr_name}")
					# end

					player_groups = {}

					if grid_size then
						players.each do |p|
							next if player.id.to_i == p[id_attr_name].to_i

							ci = GeoHelper.cell_index(p[loc_attr_name], grid_size)
							cp = GeoHelper.cell_point(ci, grid_size)

							group = player_groups[ci]
							unless group
								group = {
									players: [],
									cell_index: ci,
									cell_point: cp,
								}
							end
							num = group[:players].length
							group_centroid = group[:group_centroid]

							unless group_centroid
								group_centroid = GeoHelper.hash_from_point(p.loc)
							else 
								avg_x = group_centroid[:lng]
								avg_y = group_centroid[:lat]
								new_avg_x = (avg_x * num + p[loc_attr_name].x) / (num + 1).to_f
								new_avg_y = (avg_y * num + p[loc_attr_name].y) / (num + 1).to_f
								group_centroid = {lng: new_avg_x, lat: new_avg_y}
							end
							group[:group_centroid] = group_centroid
							player_hash = {
								id: p[id_attr_name]
							}
							group[:players] << player_hash
							player_groups[ci] = group
						end
					end

					objects = []
					player_groups.each do |cell_index, group|
						obj = {}
						obj[:loc] = group[:group_centroid]
						
						group_players = group[:players]

						if group_players.length > 1 then
							obj[:type] = "group"
							obj[:num] = group_players.length
						else
							obj[:type] = "player"
							obj[:id] = group_players[0][:id]
						end
						objects << obj
					end

					
					# Add treasure to objects

					treasure_loc = GeoHelper.hash_from_point(game.treasure_loc)
					treasure = {
						loc: treasure_loc,
						type: "treasure"
					}

					if game.treasure_holder_id then
						holder = Player.find_by_id(game.treasure_holder_id)
						if holder then
							treasure[:holder] = {
								id: holder.id,
								type: "player",
								loc: treasure_loc
							}
							treasure[:attached_at] = game.treasure_attached_at
							treasure[:safe_hold_time] = game.treasure_safe_hold_time
						end
					end

					objects << treasure

					# TODO: Add treasure object

					api_response_with(200, {
						objects: objects
					})
				end
			end
		}
	end

	def take_treasure
		safe -> {
			player = Player.by_token(params[:player_token])
			game = Game.find_by_id(params[:game_id])

			unless player and game
				error_response_with(401, "Unathorized")
			else
				attach_ok = false
			
				game.transaction do
					game.lock!
					attach_ok = game.attach_treasure_to_player_if_possible(player)
					game.save if attach_ok
				end

				if attach_ok then
					api_response_with(200, {
						game: game.to_hash
					})
				else
					error_response_with(403, "Attach failed")
				end	
			end
		}
	end

end
