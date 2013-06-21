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

end
