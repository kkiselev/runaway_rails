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
			error_response_with(501, "'change_location' is not implemented yet")
		}
	end

	def locations
		safe -> {
			error_response_with(501, "'locations' is not implemented yet")
		}
	end

	def take_treasure
		safe -> {
			error_response_with(501, "'take_treasure' is not implemented yet")
		}
	end

end
