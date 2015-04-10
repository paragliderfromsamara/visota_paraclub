class VoteValue < ActiveRecord::Base
 attr_accessible :vote_id, :value, :photo_id, :video_id, :article_id
 has_many :voices
 belongs_to :vote
 belongs_to :photo
 belongs_to :article
 
end
