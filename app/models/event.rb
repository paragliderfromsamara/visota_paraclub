class Event < ActiveRecord::Base
  attr_accessible :article_id, :content, :display_area_id, :photo_album_id, :post_date, :short_content, :status_id, :title, :video_id, :uploaded_photos, :photo_id
  has_many :photos, :dependent  => :delete_all
  belongs_to :photo_album
  belongs_to :video
  belongs_to :article
  belongs_to :photo
  require 'will_paginate'
  
  auto_html_for :content do
	html_escape
	my_youtube_msg(:width => 480, :height => 360, :span => true)
	my_vimeo(:width => 480, :height => 360, :span => true)
	vk_video_msg(:width => 480, :height => 360, :span => true)
	smiles
    link :target => "_blank", :rel => "nofollow", :class => "b_link"
	my_photo_hash
	user_hash
	theme_hash
	my_quotes
	fNum
  simple_format
  end
  
  after_save :check_photos_in_content

#Зоны видимости------------------------------------------------------------
  def display_area_list
	[
		{:value => 1, :name => 'Только главная страница'},
		{:value => 2, :name => 'Только в корне гостевой'},
		{:value => 3, :name => 'На главной странице и в корне гостевой'}
	]
  end
  def get_display_area_list_item
	value = {}
	display_area_list.each do |item|
		value = item if display_area_id == item[:value] 
	end
	return value
  end
#Зоны видимости end--------------------------------------------------------
#Статус новости------------------------------------------------------------
  def statuses_list
	[
		{:value => 1, :name => 'Не активна'},
		{:value => 2, :name => 'Активна'}
	]
  end
  def get_status_item
	value = {}
	statuses_list.each do |item|
		value = item if status_id == item[:value] 
	end
	return value
  end
#Статус новости end--------------------------------------------------------

	def alter_content
		 if short_content != '' and short_content != nil
			return short_content if short_content.strip != ''
		 end
		return content
	end
	def alter_photo(type)
		photo_tag = nil
		if video != nil
			width = '250px' if type == 'article' or type == 'thumb'
			width = '150px' if type == 'small'
			if video.image_link != '' and video.image_link != nil
				photo_tag = "<img src = '#{video.image_link}' width = #{width} align = 'left' style = 'padding-right: 5px;'/>"
			end
		else
			photo_to_return = nil
			if article != nil || photo_album != nil || photo != nil || photos != []
				if photo_album != nil
					photo_to_return = photo_album.photo
				end
				if article != nil
					photo_to_return = article.alter_photo  
				end
				if photo != nil || photos != []
					photo_to_return = photos.first if photo == nil 
					photo_to_return = photo if photo != nil 
				end
			end
			if photo_to_return != nil
				if type == 'thumb'
					photo_tag = "<img src = '#{photo_to_return.link.thumb}' align = 'left' style = 'padding-right: 5px;' />"
				elsif type == 'article'
					photo_tag = "<img src = '#{photo_to_return.link.article}' align = 'left' style = 'padding-right: 5px;' />"
				elsif type == 'small'
					photo_tag = "<img src = '#{photo_to_return.link.small}' align = 'left' style = 'padding-right: 5px;' />"
				end
			end
		end

		return photo_tag
	end
	def uploaded_photos=(attrs)
		attrs.each {|attr| self.photos.build(:link => attr)}
	end
	def check_photos_in_content
		if photos != []
			photos.each do |ph|
				if content.index("#Photo#{ph.id}") != nil and content.index("#Photo#{ph.id}") != -1
					ph.update_attributes(:status_id => 2) if ph.status_id != 2
				else
					ph.update_attributes(:status_id => 1) if ph.status_id == 2
				end
			end
		end
	end
	def link_to
		link = "/events/#{id}"
		link = "/articles/#{article.id}" if article != nil
		link = "/photo_albums/#{photo_album.id}" if photo_album != nil
		link = "/videos/#{video.id}" if video != nil
		return link
	end
end
