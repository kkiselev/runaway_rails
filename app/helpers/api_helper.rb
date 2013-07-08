module ApiHelper

	def api_response_with(status, obj)
		render status: status, text: obj.to_json
	end

	def error_response_with(status, error_message)
		api_response_with(status, {
			error: error_message
		})
	end

	def safe(actions)
		begin
			actions.call()
			
		rescue ActiveRecord::RecordNotFound => e
			error_response_with(404, e.message)

		rescue Exception => e
			error_response_with(500, e.message)
		end
	end

	def dict_with_account_and_token(account, token) 
		{
			id: account.id,
			first_name: account.first_name,
			last_name: account.last_name,
			account_token: token
		}
	end

	def dict_with_player_and_token(player, token)
		{
			id: player.id,
			loc: GeoHelper.hash_from_point(player.loc),
			player_token: token
		}
	end

end
