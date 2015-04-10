class Video < ActiveRecord::Base
  attr_accessible :article_id, :category_id, :event_id, :link, :name, :user_id, :image_link, :mini_link, :description
  belongs_to :user
  belongs_to :article
  has_many :messages, :dependent  => :delete_all
  has_one :theme, :dependent  => :destroy
  require 'will_paginate'
  #has_many :events, :dependent  => :delete_all
	auto_html_for :link do 
		my_youtube(:width => 640, :height => 480)
		my_vimeo(:width => 640, :height => 480)
		vk_video(:width => 640, :height => 480)
	end
	auto_html_for :mini_link do 
		my_youtube(:width => 320, :height => 240)
		my_vimeo(:width => 320, :height => 240)
		vk_video(:width => 320, :height => 240)
	end
	
	def alter_name
		if name.strip == '' or name == nil
			"Видео от #{created_at.strftime("%d.%m.%Y в %k:%M:%S")}"
		else
			name
		end
	end
	def visible_messages
		Message.find_all_by_video_id_and_status_id(self.id, 1, :order => 'created_at ASC')
	end
	
	before_save :make_mini_link
	after_save :make_name
	
	def make_mini_link
		self.mini_link = link
    end
	
	def make_name
		self.name = alter_name
	end
	
	 #validation    ---
	 video_regex = /(https?:\/\/(www.)?(youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/watch\?feature=(player_detailpage|player_embedded)&v=)([A-Za-z0-9_-]*)(\&\S+)?(\?\S+)?)|(<iframe\s+src="(http:\/\/vk\.com\/video_ext\.php)\?oid=(\d+)&id=(\d+)&hash=(.+)(&hd=(\d{1}))?"\s+width="(\d{1,3})"\s+height="(\d{1,3})"\s+frameborder="(\d{1})"(.+)?><\/iframe>)|(https?:\/\/(www.)?vimeo\.com\/([A-Za-z0-9._%-]*)((\?|#)\S+)?)/
	  validates :link, :presence => {:message => "Поле 'Ссылка' не должно быть пустым"},
				       :format => {:with => video_regex, :message => "Ссылка не соответствует формату youtube, vk, vimeo"},
				       :uniqueness => {:case_sensitive => false, :message => "Видео с такой ссылкой уже добавлено"}
	validates :description, :length => { :maximum => 5000, :message => "Описание не может быть более 5000 знаков"}
	validates :name, :length => { :maximum => 100, :message => "Название не может быть длиннее 100 знаков"}
					
	 #validation end---
	 #categories-------
	  def categories #в старой версии была отдельная таблица в базе
			[	
				{:value => 5, :name => 'Свободные полёты', :path_name => 'paragliding'},
				{:value => 4, :name => 'Моторные полёты', :path_name => 'power_paragliding'},
				{:value => 2, :name => 'Кайтинг', :path_name => 'kiting'},
				{:value => 3, :name => 'Клубные мероприятия', :path_name => 'club_events'},
				{:value => 1, :name => 'Разное', :path_name => 'another'}	
			]
	  end
	  
	  def category_name
		category[:name]
	  end
	  
	  def cur_category_id
		category[:value]
	  end
	  def category_path
		category[:path_name]
	  end
	  def category
		categories.each do |group|
			return group if category_id == group[:value]
		end
	  end
	  
  #categories end---
  #Просмотры--------
  	def views
		Step.find_all_by_part_id_and_page_id_and_entity_id(5, 1, self.id)
	end
  #Просмотры end
end
