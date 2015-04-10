class OldMessage < ActiveRecord::Base
  attr_accessible :content, :created_when, :user_id, :user_name
  belongs_to :user
  require 'will_paginate'
  auto_html_for :content do 
		my_youtube(:width => 480, :height => 360, :span => true)
		my_vimeo(:width => 480, :height => 360, :span => true)
		vk_video(:width => 480, :height => 360, :span => true)
		img(:height => 100)
		smiles
		link :target => "_blank", :rel => "nofollow", :class => "b_link"
  end
  
end
