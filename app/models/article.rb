class Article < ActiveRecord::Base
  attr_accessor :assigned_albums, :assigned_videos
  attr_accessible :article_type_id, :content, :event_id, :name, :user_id, :accident_date, :attachment_files, :photos, :uploaded_photos,:assigned_albums, :assigned_videos, :status_id, :visibility_status_id
  belongs_to :user
  #belongs_to :article_type
  has_many :attachment_files, :dependent  => :destroy
  has_many :photos, :dependent  => :delete_all
  has_many :photo_albums
  has_many :videos
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
  #статусы...  
  def statuses 
	[	
		{:id => 0, :value => 'draft'},	  #черновики
		{:id => 1, :value => 'visible'},  #отображенные
		{:id => 2, :value => 'to_delete'} #в очереди на удаление
	]
  end
  
  def status
	stat = 'draft'
	statuses.each do |s|
		stat = s[:value] if status_id == s[:id]
	end
	return stat
  end
  def v_statuses #статус отображения
  [
	{:id => 1, :value => 'visible', :img => '/', :ru => 'Видна всем'},
	{:id => 2, :value => 'hidden', :img => '/', :ru => 'Видна только авторизованным пользователям'}
	]
  end
  
  def v_status #статус отображения
	stat = 'visible'
	v_statuses.each do |s|
		stat = s[:value] if s[:id] == self.visibility_status_id
	end
	return stat
  end
#статусы end...
    #Валидация статей
	 validate :validate_articles, :on => :create
	 def validate_articles
		if status_id != 0
			case article_type_id
				when 1
				validate_flight_accidents #Ошибки при описании летного происшествия
				when 2
				validate_documents #Ошибки при добавлении документов
				when 3
				validate_reports
				when 4
				validate_reports
				when 5
				validate_reports
				when 6
				validate_risen_from_the_ruin #Ошибки при добавлении отчётов
			end
		end
	 end
	 
	def validate_flight_accidents
		errors.add(:content, "Постарайтесь уместить описание Лётного происшествия в 20 000 знаков") if content.length > 20000 
		errors.add(:content, "Опишите лётное происшествие") if content.strip == ''  
		
	end
	
	def validate_reports
		errors.add(:content, "Постарайтесь уместить отчёт в 40 000 знаков") if content.length > 40000 
		errors.add(:content, "Заполните поле Содержание отчёта") if content.strip == ''  
		errors.add(:name, "Введите название описываемого в отчёте мероприятия") if name.strip == '' 
		errors.add(:name, "Название описываемого в отчёте мероприятия не должно быть длиннее 100 знаков") if name.length > 100
	end
	
	def validate_risen_from_the_ruin
		errors.add(:content, "Постарайтесь уместить отчёт в 40 000 знаков") if content.length > 40000 
		errors.add(:content, "Заполните поле Содержание статьи") if content.strip == ''  
		errors.add(:name, "Введите название статьи") if name.strip == '' 
		errors.add(:name, "Название описываемого в отчёте мероприятия не должно быть длиннее 100 знаков") if name.length > 100
	end
	
	def validate_documents
		errors.add(:attachment_files, "Прикрепить один или несколько файлов") if attachment_files == [] or attachment_files == nil
		errors.add(:content, "Описание не должно превышать 500 знаков") if content.length > 500
		errors.add(:name, "Введите название загружаемого материала") if name.strip == '' 
		errors.add(:name, "Название загружаемого материала не должно быть длиннее 100 знаков") if name.length > 100
	end
   #Валидация статей end
   after_save :get_albums, :get_videos, :check_photos_in_content
   before_destroy :unbind_albums, :unbind_videos
   def types
	[
		{:value => 3, :form_title => 'Новый отчёт', :add_but_name => 'отчёт', :name => 'Отчёт', :multiple_name => 'Отчёты по мепроприятиям', :link => 'reports'},
		{:value => 5, :form_title => 'Новый отзыв', :add_but_name => 'отзыв', :name => 'Отзыв', :multiple_name => 'Отзывы', :link => 'reviews'},
		{:value => 1, :form_title => 'Новый отчёт о лётном происшествии', :add_but_name => 'отчёт о лётном происшествии', :name => 'Отчёт о лётном происшествии', :multiple_name => 'Лётные происшествия', :link => 'flight_accidents'},
		{:value => 4, :form_title => 'Новая статья', :add_but_name => 'статью', :name => 'Статья', :multiple_name => 'Статьи', :link => 'club_articles'},
		{:value => 6, :form_title => 'Новая статья', :add_but_name => 'статью', :name => 'Восставшие из руин', :multiple_name => 'Восставшие из руин', :link => 'risen_from_the_ruin'},
		{:value => 2, :form_title => 'Новый документ', :add_but_name => 'документ', :name => 'Документ', :multiple_name => 'Документы', :link => 'documents'}
	]
   end
   
   def type
	types.each do |t|
		return t if self.article_type_id == t[:value]
	end
	return nil
   end
   
   def type_path #Возвращает ссылку конкретный раздел с материалами
    t_path = '/articles'
	if article_type_id != nil
		type = get_type_by_id(article_type_id)
		t_path = t_path + "?c="+type[:link] if type != nil
	end
   end
   
   def alter_date
		self.accident_date.nil? ? self.created_at : self.accident_date
   end
   
   def alter_name
	if article_type_id == 1
		"Лётное происшествие от #{alter_date.to_s(:ru_datetime)}"
	else
		name
	end
   end
   def visible_photos
		photos.where(:visibility_status_id => 1)
   end   
   def alter_photo
	if photos != []
		return photos.first.link.thumb
	else
		if photo_albums != []
			return photo_albums.first.get_photo.link.thumb
		else
			return nil
		end
	end
   end
   
   def get_type_by_id(id)
	value = nil
	types.each do |type|
		value = type if type[:value] == id.to_i
	end
	return value
   end
   
   def type_name_multiple
		t = get_type_by_id(article_type_id)
		return t[:multiple_name]
   end
   
   def type_name_single
		t = get_type_by_id(article_type_id)
		return t[:name]
   end
   
   def attachment_files=(attrs)
	attrs.each {|attr| self.attachment_files.build(:link => attr, :user_id => self.user_id, :directory => "articles/#{self.article_type_id}")}
   end
   
  def uploaded_photos=(attrs)
	attrs.each {|attr| self.photos.build(:link => attr, :user_id => self.user_id)}
  end
  
  def already_assigned_albums
	v = ''
	if photo_albums != []
		photo_albums.each do |album|
			v += "[#{album.id.to_s}]"
		end
	end
	return v
  end
  
  def already_assigned_videos
	v = ''
	if videos != []
		videos.each do |video|
			v += "[#{video.id.to_s}]"
		end
	end
	return v
  end
  
  def get_albums #Привязывает к статье фотоальбомы
	if getBindedAlbumsIdsArray == []
		if assigned_albums != nil and assigned_albums != ''
			ids = getIds(assigned_albums)
			bindAlbumsById(ids, self.id)
		end
	else
		if assigned_albums != nil and assigned_albums != ''
			ids = getIds(assigned_albums)
			bindArr = ids - getBindedAlbumsIdsArray
			unbindArr = getBindedAlbumsIdsArray - ids
			bindAlbumsById(unbindArr, nil) if unbindArr != []
			bindAlbumsById(bindArr, self.id) if bindArr != []
		elsif assigned_albums == ''
			unbind_albums
		end
	end
  end
  
  def bindAlbumsById(arr, val)
	albums = PhotoAlbum.find_all_by_id((arr))
	if albums != []
		albums.each do |alb|
			alb.update_attributes(:article_id => val)
		end
	end
  end
  
  def bindVideosById(arr, val)
	videos = Video.find_all_by_id((arr))
	if videos != []
		videos.each do |vid|
			vid.update_attributes(:article_id => val)
		end
	end
  end
  
  
  def getBindedAlbumsIdsArray
	arr = []
	if photo_albums != []
		photo_albums.each {|album| arr[arr.length] = album.id} 
	end
	return arr
  end
  
  def getBindedVideosIdsArray
	arr = []
	if videos != []
		videos.each {|video| arr[arr.length] = video.id} 
	end
	return arr
  end
  
  def get_videos #Привязывает к статье фотоальбомы
	if getBindedVideosIdsArray == []
		if assigned_videos != nil and assigned_videos != ''
			ids = getIds(assigned_videos)
			bindVideosById(ids, self.id)
		end
	else
		if assigned_videos != nil and assigned_videos != ''
			ids = getIds(assigned_videos)
			bindArr = ids - getBindedVideosIdsArray 
			unbindArr = getBindedVideosIdsArray  - ids
			bindVideosById(unbindArr, nil) if unbindArr != []
			bindVideosById(bindArr, self.id) if bindArr != []
		elsif assigned_videos == ''
			unbind_videos
		end
	end
  end
  
  def getIds(str)
	ids = []
	id = ''
	str.chars do |ch|
		if ch != '[' and ch != ']'
			id += ch
		elsif ch == ']'
			ids[ids.length] = id
			id = ''
		end
	end
	return ids
  end
  
  def unbind_albums
	if photo_albums != []
		photo_albums.each do |album|
			album.update_attributes(:article_id => nil)
		end
	end
  end
  
  def unbind_videos
	if videos != []
		videos.each do |v|
			v.update_attributes(:article_id => nil)
		end
	end
  end
  
  def check_photos_in_content 
	if self.photos != [] and self.photos != nil
		self.photos.each do |ph|
			self.check_photo_in_content(ph)
		end
	end
  end

 def check_photo_in_content(ph) #делаем фотографию невидимой в основном списке фотографий сообщения и делаем видимой, если её там нет
		if self.content.index("#Photo#{ph.id}") != nil and self.content.index("#Photo#{ph.id}") != -1
			ph.set_as_hidden
		else
			ph.set_as_visible
		end  
  end 
 
  def clean
  end
end