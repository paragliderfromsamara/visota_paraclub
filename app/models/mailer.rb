class Mailer < ActiveRecord::Base
  belongs_to :user
  attr_accessible :album, :article, :email, :message, :photo_comment, :user_id, :video, :video_comment
end
