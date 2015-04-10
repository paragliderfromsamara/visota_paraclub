class Voice < ActiveRecord::Base
  attr_accessible :vote_value_id, :user_id, :vote_id
  belongs_to :user
  belongs_to :vote_value
  belongs_to :vote
  
  
  
end
