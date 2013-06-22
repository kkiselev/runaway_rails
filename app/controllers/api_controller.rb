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
	# Response: 
	#  	{ "account_id" : <account_id> }
	#
	def register
		safe -> {
			account = Account.new
			account.login = params[:login]
			account.password = params[:password]
			account.last_name = params[:last_name]
			account.first_name = params[:first_name]
			account.save!

			api_response_with(200, {
				account_id: account.id
			})
		}
	end

	# /auth
	#
	# POST
	# 	:login
	#  	:password
	#
	# Response: 
	#  	{ "account_id" : <account_id> }
	#
	def auth
		safe -> {
			login = params[:login]
			pass = params[:password]

			account = Account.where("login = :login AND password = :password", {login: params[:login], password: params[:password]}).first
			unless account 
				error_response_with(401, "Authorization failed")
			else 
				api_response_with(200, {
					account_id: account.id
				})
			end
		}
	end

	# /game/:game_id/join_game
	#
	# POST
	# 	:account_id
	#
	# Response: 
	#  	{ "player_id" : <player_id> }
	#
	def join_game
		safe -> {
			account = Account.find_by_id(params[:account_id])
			unless account
				error_response_with(401, "Unathorized")
			else 
				game = Game.find_by_id(params[:game_id])
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
					response = {
						player_id: player.id
					}
					api_response_with(200, response)
				end	
			end
		}
	end

	def change_location
		safe -> {
			player = Player.find_by_id(params[:player_id])
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
						error_response_with(409, "Location is not in the game area")
					end
				end
			end
		}
	end

	def locations
		safe -> {
			player = Player.find_by_id(params[:player_id])
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
					if loc.within?(game.area) then
						players = Player.within_box()

						#TODO: clustering is needed here

						objects = []
						players.each do |player|
							obj = {
								id: player.id,
								name: player.name,
								loc: GeoHelper.hash_from_point(player.loc),
								type: "player"
							}
							objects << obj
						end
						api_response_with(200, {
							objects: objects
						})
					else
						error_response_with(409, "Location is not in the game area")
					end
				end
			end
		}
	end

	def take_treasure
		safe -> {
			error_response_with(501, "'take_treasure' is not implemented yet")
		}
	end

end
