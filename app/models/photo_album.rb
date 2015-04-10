class PhotoAlbum < ActiveRecord::Base
  attr_accessible :article_id, :category_id, :description, :name, :photo_id, :user_id, :uploaded_photos, :status_id, :visibility_status_id
  belongs_to :user
  belongs_to :photo
  has_one :theme, :dependent  => :destroy
  has_many :photos, :dependent  => :delete_all
  has_many :messages, :dependent  => :delete_all
  #belongs_to :category 
  #has_many :events, :dependent  => :delete_all
  belongs_to :article
  require 'will_paginate'
  after_create :setAlbumPhoto
  #валидация альбома---------------------------------------------
	validates :name, :presence => {:message => "Поле 'Название' не должно быть пустым"},
				     :length => { :maximum => 60, :message => "Название не может быть длиннее 60-ти знаков"},
				     :uniqueness => {:message => "Альбом с таким названием уже существует"},
					 :allow_nil => true,
					 :if => :is_not_draft?
					 
	validates :description, :length => { :maximum => 1000, :message => "Описание не может быть длиннее 1000-ти знаков"},
				            :allow_blank => true,
							:if => :is_not_draft?
	
	validate :photos_check, :on => :create
	def photos_check
		if (self.photos == nil || self.photos == []) and self.status_id != 0
			errors.add(:photos, "Необходимо выбрать одну, или несколько фотографий") if self.user.album_draft.photos == [] 
		end
	end
	def is_not_draft?
		return true if self.status_id != 0
		return false
	end
	def assign_entities_from_draft
		draft = self.user.album_draft
		if draft.photos != []
			draft.photos.each do |ph|
				ph.update_attributes(:photo_album_id => self.id, :status_id => 1, :visibility_status_id => 1)
			end
			#draft.clean
		end
		
	end
  #валидация альбома end-----------------------------------------
  
  #categories-------
  def categories #в старой версии была отдельная таблица в базе
		[
			{:value => 3, :name => 'Клубные мероприятия', :path_name => 'club_events'},
			{:value => 5, :name => 'Свободные полёты', :path_name => 'paragliding'},
			{:value => 4, :name => 'Моторные полёты', :path_name => 'power_paragliding'},
			{:value => 2, :name => 'Кайтинг', :path_name => 'kiting'},
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
  def uploaded_photos=(attrs)
	attrs.each {|attr| self.photos.build(:link => attr, :user_id => self.user_id, :category_id => self.category_id)}
  end
  
  def setAlbumPhoto
	photo_id = photos.first
  end
  
  def get_photo
	if photo_id == nil
		return photos.first
	else
		return photo
	end
  end
  
  def index_photos
	self.photos.where(:status_id => 1).order('created_at ASC').limit(10)
  end
  
  def comments
	self.messages.where(:status_id => 1).order('created_at ASC')
  end
  
  def views
	Step.find_all_by_part_id_and_page_id_and_entity_id(3,1,self.id)
  end
  #статусы...  
  def statuses 
	[	
		{:id => 0, :value => 'draft', :ru => 'Черновик'},	  #черновики
		{:id => 1, :value => 'visible', :ru => 'Отображён'},  #отображенные
		{:id => 2, :value => 'hidden', :ru => 'Скрыт'},	  #скрытые
		{:id => 3, :value => 'to_delete', :ru => 'В удалённых'} #в очереди на удаление
	]
  end
  
  def status
	stat = 'draft'
	statuses.each do |s|
		stat = s[:value] if status_id == s[:id]
	end
	return stat
  end
  
  def status_ru
	stat = 'Не определён'
	statuses.each do |s|
		stat = s[:ru] if status_id == s[:id]
	end
	return stat
  end
  
  def visible_photos #Видимые фотографии
	self.photos.where(:status_id == 1).order('created_at ASC')
  end
#статусы end...

#Управление отображением альбома
  def clean 
	self.update_attributes(:name => '', :description => '', :category_id => nil)
	if self.photos != []
		self.photos.each do |ph|
			ph.destroy
		end
	end
  end
  def set_as_visible
	self.update_attributes(:status_id => 1)
	if photos != []
		photos.each do |ph|
			ph.set_as_visible #Помечаем и переносим в папку удалённые
		end
	end
	if messages != []
		messages.each do |msg|
			msg.update_attributes(:status_id => 1) #Помечаем комментарии к альбому как удалённые
		end
	end
  end
  
  def set_as_delete #Меняем статус альбома на удалённый и все связанные с ним сущности
	self.update_attributes(:status_id => 3)
	if photos != []
		photos.each do |ph|
			ph.set_as_delete #Помечаем и переносим в папку удалённые
		end
	end
	if messages != []
		messages.each do |msg|
			msg.update_attributes(:status_id => 3) #Помечаем комментарии к альбому как удалённые
		end
	end
  end
#Управление отображением альбома end 
end
