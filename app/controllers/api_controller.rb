class ApiController < ApplicationController
	include ApiHelper

	def register
		safe -> () {
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

	def auth
		safe -> () {
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

	def join_game
		safe -> () {
			account = Account.find(params[:account_id])
			unless account
				error_response_with(401, "Unathorized")
			else 
				game = Game.find(params[:game_id])
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
		safe -> () {
			api_response_with(200, {
				game_id: params[:game_id]
			})
		}
	end

	def locations

	end

	def take_treasure
	end

end
