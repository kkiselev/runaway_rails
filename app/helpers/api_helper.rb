module ApiHelper

	def api_response_with(obj)
		render text: obj.to_json
	end

end
