class Account < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :login, :password
  has_many :players
end
