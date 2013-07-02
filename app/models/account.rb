class Account < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :login, :password
  has_many :players

  class << self
  	
  	def by_token(account_token)
  		account_id = account_token.to_i
  		Account.find_by_id(account_id)
  	end

  end

end
