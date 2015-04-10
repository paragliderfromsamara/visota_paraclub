#12.02.2014 - Создание
#			- Добавлено логирование пользователя
#			- Добавлен массив user_groups
#			- Добавлен блок antibot_images
#			- Добавлен блок Uploaders
#14.02.2014 - Добавлена функция alter_avatar и alter_avatar_thumb
#15.02.2014 - Добавлен блок Mailers
#21.02.2014 - Добавлены фотоальбомы 


require 'digest'
class User < ActiveRecord::Base
  attr_accessor :password, :old_password, :current_password
  attr_accessible :password, :avatar, :cell_phone, :email, :email_status, :encrypted_password, :full_name, :icq, :inform, :name, :photo, :salt, :skype, :user_group_id, :password_confirmation, :avatar_cache, :photo_cache, :old_password, :current_password
  require 'will_paginate'
#--------Old_messages---------------------------------------------
has_many :old_messages
#--------Old_messages end-----------------------------------------
#--------Videos---------------------------------------------
has_many :videos, :dependent  => :delete_all
#--------Videos end-----------------------------------------
  
#--------PhotoAlbums---------------------------------------------
has_many :photo_albums, :dependent  => :delete_all
#--------PhotoAlbums end-----------------------------------------

#--------PhotoAlbums---------------------------------------------
has_many :photos, :dependent  => :delete_all
#--------PhotoAlbums end-----------------------------------------

#--------Themes--------------------------------------------------
has_many :themes
#--------Themes end----------------------------------------------

#--------Messages--------------------------------------------------
has_many :messages
#--------Messages end----------------------------------------------
#--------steps-----------------------------------------------------
has_many :steps
#--------steps end-------------------------------------------------
#--------Mailers-------------------------------------------------
has_one :mailer, :dependent  => :delete
	def has_mailer?
		return mailer if mailer != nil and email == mailer.email
		return nil if mailer == nil or email != mailer.email
	end
	def make_mailer
		if !has_mailer?
			self.create_mailer(:album => 'no', :video => 'no', :message => 'no', :article => 'no', :photo_comment => 'no', :video_comment => 'no', :email => email)
		end
	end
#--------Mailers end---------------------------------------------
#UserDrafts------------------------------------------------------
#def themeMessageDraft #Черновик для сообщений в темах
#	msg_draft = Message.find_by_user_id_and_topic_id_and_theme_id_and_status_id(self.id, 0, 0, 0)
#	msg_draft = self.messages.create(:theme_id => 0, :topic_id => 0, :status_id => 0) if msg_draft == nil
#	return msg_draft
#end
#def photoCommentDraft #Черновик для комментариев к фото
#end
#def videoCommentDraft #Черновик для комментариев к видео
#end
#def photoAlbumDraft #Черновик для альбома
#end
#UserDrafts end--------------------------------------------------
#--------Uploaders-----------------------------------------------
mount_uploader :avatar, UserAvatarUploader
mount_uploader :photo, UserPhotoUploader
#--------Uploaders end-------------------------------------------
  def visible_name(user_group)
	if !full_name? || user_group == 'guest' || user_group == 'bunned' || user_group == 'new_user' 
		return name
	else
		return full_name
	end
  end
  def alter_avatar
	user_avatar = '/files/undefined.png'
		if avatar?
			user_avatar = avatar
		end
	return user_avatar
  end
  def alter_avatar_thumb
	user_avatar = '/files/undefined_thumb.png'
		if avatar?
			user_avatar = avatar.thumb
		end
	return user_avatar
  end
  def empty_card
	"
		<table style = 'height: 30px;'>
					<tr>
						<td valign = 'middle' align = 'left' style = 'width: 30px;'><img class = 'mini_link' src = '#{alter_avatar_thumb}'></td>
						<td valign = 'middle' align = 'left'><a class = 'b_link' href = '/users/#{id}' target = '_blank' >#{name}</a></td>
					</tr>
		</table>
	"
  end
  def role_card(user_role)
	"
		<table style = 'height: 30px;'>
					<tr>
						<td valign = 'middle' align = 'left'><p class = 'istring'>#{user_role}</p></td>
						<td valign = 'middle' align = 'left' style = 'width: 30px;'><img class = 'mini_link' src = '#{alter_avatar_thumb}'></td>
						<td valign = 'middle' align = 'left'><a class = 'b_link' href = '/users/#{id}' target = '_blank' >#{name}</a></td>
					</tr>
		</table>
	"
  end

  def user_groups #в старой версии была отдельная таблица в базе
		[
			{:value => 7, :name => 'Удалённый'},#manager
			{:value => 6, :name => 'Руководитель клуба'},#manager
			{:value => 2, :name => 'Клубный пилот'},	 #club_pilot
			{:value => 3, :name => 'Друг клуба'},		 #friend
			{:value => 5, :name => 'Вновь прибывший'},   #new_user
			{:value => 4, :name => 'Бан лист'},		 #bunned
			{:value => 1, :name => 'Site Admin'},		 #admin
			{:value => 0, :name => 'Super Admin'}    #super_admin
		]
  end
  
  def club_pilots
	User.find_all_by_user_group_id([0,1,2,6])
  end
  
  def club_friends
	User.find_all_by_user_group_id(3)
  end
  
  def new_users
	User.find_all_by_user_group_id(5)
  end
  
  def bunned
	User.find_all_by_user_group_id(4)
  end
  
  
  
  def group_name
	user_group[:name]
  end
  
  def group_id
	user_group[:value]
  end
  
  def user_group
	user_groups.each do |group|
		return group if user_group_id == group[:value]
	end
  end
  #управление черновиками тем и сообщений
  def message_draft #выдает, а если необходимо создает черновик сообщения
	draft = Message.find_by_user_id_and_status_id(self.id, 0)
	draft = self.messages.create(:status_id => 0) if draft == nil 
	return draft
  end
  def theme_draft #выдает, а если необходимо создает черновик темы
	draft = Theme.find_by_user_id_and_status_id(self.id, 0)
	if draft == nil
		draft = Theme.new(:user_id => self.id, :status_id => 0)# if draft == nil 
		draft.save(:validate => false) #отключаем проверку длины названия темы
	end
	return draft
  end
  def album_draft 
	draft = PhotoAlbum.find_by_user_id_and_status_id(self.id, 0)
	if draft == nil
		draft = PhotoAlbum.new(:user_id => self.id, :status_id => 0)# if draft == nil 
		draft.save(:validate => false) #отключаем проверку длины названия темы
	end
	return draft
  end
  def article_draft 
	draft = Article.find_by_user_id_and_status_id(self.id, 0)
	if draft == nil
		draft = Article.new(:user_id => self.id, :status_id => 0)# if draft == nil 
		draft.save(:validate => false) #отключаем проверку длины названия темы
	end
	return draft
  end
  #управление черновиками тем и сообщений end
  
  #Валидация пользователя
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :password, :presence => {:message => "Введите пароль длинной 6-40 символов"},
					   :confirmation => {:message => "Введённый пароль не совпадает с подтверждением"},
					   :length => {:within => 6..40, :message => "Длина пароля должна быть не менее 6 и не более 40 знаков"},
					   :on => :create

  validates :name, :presence => {:message => "Поле 'Ник' не должно быть пустым"},
				   :length => { :maximum => 32, :message => "Ник не может быть длиннее 32-х знаков"},
				   :uniqueness => {:message => "Ник занят другим пользователем"},
				   :on => :create

  validates :email,  :presence => {:message => "Поле 'E-mail' не должно быть пустым"},
				     :format => {:with => email_regex, :message => "Поле 'E-mail' не соответсвует формату адреса электронной почты 'user@mail-provider.ru'"},
				     :uniqueness => {:case_sensitive => false, :message => "E-mail уже используется"},
					 :allow_nil => true
  
  validate :old_password_exists, :on => :update
  validate :current_password_check, :on => :update
  
  def current_password_check
	if current_password != nil
		errors.add(:current_password, "Необходимо ввести свой текущий пароль") if  current_password.strip == ''
		errors.add(:current_password, "Пароль введён неверно") if current_password.strip != '' and encrypted_password != encrypt(current_password)
	end
  end
  def old_password_exists
	if old_password != nil
		errors.add(:old_password, "Необходимо ввести свой старый пароль") if old_password.strip == ''
		errors.add(:old_password, "Старый пароль введён неверно") if old_password.strip != '' and encrypted_password != encrypt(old_password) 
	end
	if password != nil
		errors.add(:password, "Введите новый пароль длинной 6-40 символов") if password.strip == '' 
		errors.add(:password, "Введённый пароль не совпадает с подтверждением") if password.strip != password_confirmation.strip 
		errors.add(:password, "Длина пароля должна быть не менее 6 и не более 40 знаков") if password.strip.length < 6 or password.strip.length > 40 and password.strip != ''
	end
  end
  #antibot_images----------------------------------------------------------------
  def antibot_images
	[
		{:name => '2G3uup', :value => 'adN7wJ'},
		{:name => 'hcvu907', :value => 'km1F9g'},
		{:name => 'Krfereg', :value => 'cR1wQ'},
		{:name => 'xYp89n', :value => 'tU560m'}
	]
  end
  
  def image_valid?(img_val, img_name)
	img_val == get_antibot_image_by_name(img_name)
  end
  
  def get_default_antibot_image
	array = antibot_images.shuffle
	return array.first
  end
  
  def get_antibot_image_by_name(img_name)
	value = ''
		antibot_images.each do |image|
			value = image[:value] if img_name == image[:name]
		end
	return value
  end
#antibot_images end------------------------------------------------------------
  before_save :encrypt_password
  after_save :make_mailer

  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

    def self.authenticate(name, submitted_password)
    user = find_by_name(name)
    return nil  if user.nil?
    return user if user.has_password?(submitted_password)
  end
  
	def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
	(user && user.salt == cookie_salt) ? user : nil
    end  
 #feed functions for current_user--------------------------------------------------------------------------------
  def theme_with_user_ids_for_feed(is_not_authorized) 
	ids_arr = []
	value = []
	v_status_id = 1 if is_not_authorized
	v_status_id = [1,2] if !is_not_authorized
	userThemesMessages = messages.select("DISTINCT theme_id").where(:theme_id != nil, :status_id => 1)
	theme_where_wrote_ids = themes.select(:id).where(:id => userThemesMessages, :status_id => [1,3], :visibility_status_id => v_status_id)
	self_themes_ids = themes.select(:id).where(:status_id => [1,3], :visibility_status_id => v_status_id)
	ids_arr += theme_where_wrote_ids if theme_where_wrote_ids != [] #Ids тем в которых пользователь писал
	ids_arr += self_themes_ids if self_themes_ids != [] #Ids тем которые пользователь создал
	ids_arr.uniq! if ids_arr != []
	value = Theme.find_all_by_id(ids_arr, :order => 'created_at DESC') if ids_arr != []
	return value
  end
  
  def answerMessages(is_not_authorized)
	value = []
	ids_arr = []
	v_status_id = 1 if is_not_authorized
	v_status_id = [1,2] if !is_not_authorized
	myMsgsIDs = messages.select(:id).where(:status_id => 1)
	myThIDs = themes.select(:id).where(:status_id => [1,3], :visibility_status_id => v_status_id)
	if myThIDs != []
		msgsInMyThemes = Message.select(:id).where(:status_id => 1, :theme_id => myThIDs)
	end
	if myMsgsIDs != []
		answrToMyMsgs = Message.select(:id).where(:message_id => myMsgsIDs, :status_id => 1)
	end
	ids_arr += msgsInMyThemes if msgsInMyThemes != []
	ids_arr += answrToMyMsgs if answrToMyMsgs != []
	ids_arr -= myMsgsIDs
	ids_arr.uniq! if ids_arr != []
	value = Message.find_all_by_id(ids_arr, :order => 'created_at DESC') if ids_arr != []
	return value
  end
  
  def not_current_user_messages #сообщения других юзеров
	Message.find_all_by_theme_id_and_status_id(theme_with_user_ids_for_feed, 1, :conditions => "user_id != #{self.id}")
  end
  
  def themes_without_current_user(is_not_authorized) #Темы в которых пользователь не принимал участия
	result_themes = []
	v_status_id = 1 if is_not_authorized
	v_status_id = [1,2] if !is_not_authorized
	all_themes = Theme.where(:visibility_status_id => v_status_id, :status_id => [1, 3])
	with_user_themes = Theme.where(:user_id => self.id, :visibility_status_id => v_status_id, :status_id => [1, 3])
	result_themes = all_themes - with_user_themes
	return result_themes
  end
 #feed functions for current_user end----------------------------------------------------------------------------
  private
  
  def encrypt_password
	self.salt = make_salt if new_record?
	self.encrypted_password = encrypt(password) if password != nil and password != '' or password_confirmation != password
  end	
  
  def encrypt(string)
	secure_hash("#{salt}--#{string}")
  end
  
  def make_salt 
	secure_hash("#{Time.now.utc}--#{password}")
  end
  
  def secure_hash(string)
	Digest::SHA2.hexdigest(string)
  end
  #Логирование пользователя end
end
