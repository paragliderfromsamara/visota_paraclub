class Theme < ActiveRecord::Base
  #to_do!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  #после добавления индивидуальной рассылки по теме сделать:
  #---------при объединении тем рассылку от сливаемой темы привязять к целовой теме
  #---------при полном удалении темы удалять и рассылки
  #после добавления лайков:
  #---------при объединении тем все лайки от сливаемой темы привязывать к создаваемому сообщению
  #---------при полном удалении темы удалять и лайки
  
  
  attr_accessible :last_message_date, :name, :status_id, :topic_id, :user_id, :content, :photos, :uploaded_photos, :video_id, :photo_album_id, :updater_id, :attachment_files, :created_at, :updated_at, :merge_with, :visibility_status_id
 
  has_many :messages, :dependent  => :delete_all
  belongs_to :user
  belongs_to :topic
  belongs_to :video
  belongs_to :photo_album
  has_many :attachment_files, :dependent  => :delete_all
  has_many :photos, :dependent  => :delete_all
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
	#start_quote
	#end_quote
    simple_format
  end
  after_save :check_photos_in_content
  after_create :last_msg_upd_after_create
  before_save :check_visibility_status
  def uploaded_photos=(attrs)
	attrs.each {|attr| self.photos.build(:link => attr, :user_id => self.user_id)}
  end
  
  def list_photos#не используется
	"Заменить на theme_list_photos(th) а list_photos в theme.rb удалить"
  end

  def attachment_files=(attrs)
	attrs.each {|attr| self.attachment_files.build(:link => attr, :user_id => self.user_id, :directory => "themes/#{self.name}")}
  end
  
  def last_message #находим последнее сообщение темы
	Message.find_by_theme_id_and_status_id(self.id, 1, :order => 'created_at DESC')
  end
#Валидация--------------------------------------------------------------------------
 validates :name, :presence => {:message => "Поле 'Заголовок темы' не должно быть пустым"},
				   :length => { :maximum => 100, :message => "Заголовок темы должен быть длиннее 100 символов"},
				   #:on => :create
				   :if => :is_not_draft?
 validates :content, :presence => {:message => "Поле \"Содержимое\" не должно быть пустым"},
				     :length => { :maximum => 15000, :message => "Содержимое темы не должно быть длиннее 15000 символов"},
				     #:on => :create
				     :if => :has_attachments_and_photos?
				   
  validate :uniqless_name_check
  validate :check_user_permission, :on => :create
  validate :check_visibility_status, :on => :create
  
  def is_not_draft?
	return false if self.status_id == 0
	return true if self.status_id != 0
  end
  def has_attachments_and_photos?	
	if (self.photos == [] || self.photos == nil) and (self.attachment_files == [] || self.attachment_files == nil)and status_id != 0 and self.user.theme_draft.photos == []
		return true
	else
		return true if self.content.strip.length > 0
		return false if self.content.strip.length == 0
	end
  end
  
  def uniqless_name_check
	if self.name != nil and self.name != ''
		th = Theme.find_by_name_and_topic_id_and_status_id(self.name, self.topic_id, 1)
		errors.add(:content, "Тема с таким названием уже существует в данном разделе") if self != th and th != nil

	end
	
  end
  
  def check_user_permission
	if !self.user.nil?
		if (self.user.user_group_id == nil || self.user.user_group_id == 7 || self.user.user_group_id == 4) || (self.topic_id != 6 and self.user.user_group_id == 5) 
			errors.add(:user_id, "У Вас недостаточно прав для создания новой темы.")
		end
	else
		errors.add(:user_id, "У Вас недостаточно прав для создания новой темы.")
	end
  end
  
  def check_visibility_status
	self.visibility_status_id = 1 if self.visibility_status_id == nil
  end
#Валидация end----------------------------------------------------------------------
#статусы...  
  def statuses 
	[	
		{:id => 0, :value => 'draft', :img => '/files/unlock_g.png', :ru => 'Черновик'},	  #черновики
		#отображенные
		{:id => 1, :value => 'open', :img => '/files/unlock_g.png', :ru => 'Открыта'},     #отображенные
		{:id => 2, :value => 'open_to_delete', :img => '/files/unlock_g.png', :ru => 'Удалена'},#в очереди на удаление
		{:id => 3, :value => 'closed', :img => '/files/lock_g.png', :ru => 'Закрыта'},    #Тема закрыта
		{:id => 4, :value => 'closed_to_delete', :img => '/files/lock_g.png', :ru => 'Закрыта и удалена'}    #Тема закрыта    #Тема закрыта и удалена
		#отображенные end
	]
  end
  def status
	statuses.each do |s|
		return s[:value] if s[:id] == self.status_id
	end
  end
  def v_statuses #статус отображения
	[
	{:id => 1, :value => 'visible', :img => '/', :ru => 'Для всех'},
	{:id => 2, :value => 'hidden', :img => '/files/privacy_g.png', :ru => 'Только для авторизванных пользователей'}
	]
  end
  def v_status #статус отображения
	stat = 'visible'
	v_statuses.each do |s|
		stat = s[:value] if s[:id] == self.visibility_status_id
	end
	return stat
  end
  def statusHash
	statuses.each do |s|
		return s if s[:id] == self.status_id
	end
  end
  def vStatusHash
	v_statuses.each do |s|
		return s if s[:id] == self.visibility_status_id
	end
  end
#статусы end...  
  def merge(new_topic, new_theme) #объединение тем 
	message_in_target_theme = Message.new(
												:user_id => self.user_id, 
												:updater_id => self.updater_id, 
												:content => self.content, 
												:theme_id => new_theme.id, 
												:topic_id => new_topic.id, 
												:status_id => 1, 
												:created_at => self.created_at, 
												:updated_at => self.updated_at, 
												:visibility_status_id => new_theme.visibility_status_id
											) #1. Создаём в целевой теме сообщение с содержимым сливаемой темы
	message_in_target_theme.save(:validate => false)
	if self.photos != []
		 self.photos.each do |ph|
			ph.update_attributes(:message_id => message_in_target_theme.id, :theme_id => nil) #3. Переносим фотографии в message_in_target_theme
			if ph.status == 'normal' and new_theme.v_status == 'hidden' 
				ph.update_attribute(:status_id, 4) #on_hidden_entity
			elsif ph.status == 'normal' and new_theme.v_status == 'visible'
				ph.update_attribute(:status_id, 1) #normal
			end
		end
	end
	if self.attachment_files != []
		self.attachment_files.each do |af|
			af.update_attributes(:message_id => message_in_target_theme.id, :theme_id => nil) #4. Переносим вложения в message_in_target_theme
		end
	end 
	if self.messages != []
		self.messages.each do |msg|
			mes_id = message_in_target_theme.id if msg.message_id == nil #сообщение как ответ на message_in_target_theme если оно не является ответом на какое-либо сообщение
			mes_id = msg.message_id if msg.message_id != nil #не изменяем если является
			msg.update_attributes(
									:theme_id => new_theme.id, 
									:topic_id => new_topic.id, 
									:message_id => mes_id
								  )# Переносим в целевую тему все сообщения из текущей в :base_theme_id записываем id сливаемой (базовой) темы (При условии сохранения сливаемой темы)
			msg.updatePhotosStatusesAfterSave
		end
	end
	
	self.destroy
 #Объединение тем
  #1. Создаём в целевой теме сообщение с содержимым сливаемой темы
  #2. Переносим в целевую тему все сообщения из текущей в :base_theme_id записываем id сливаемой (базовой) темы
  #3. Переносим фотографии в message_in_target_theme
  #4. Переносим вложения в message_in_target_theme
  #5. Обновление текущей темы
  #6. Создание информационного сообщения
  end
  
  def delete_merged_theme
	self.unbind_photos
	self.attachment_files
  end
  def status
	stat = 'draft'
	statuses.each do |s|
		stat = s[:value] if status_id == s[:id]
	end
	return stat
  end
#статусы end...
  def last_msg_upd
	date = self.last_message.created_at if self.last_message != nil
	date = self.created_at if self.last_message_date == nil
	self.update_attribute(:last_message_date, self.created_at) if self.last_message_date != date
  end
  def last_msg_upd_after_create
	self.update_attribute(:last_message_date, self.created_at)
  end

#управление содержимым  
  def check_photos_in_content 
	if self.photos != [] and self.photos != nil
		self.photos.each do |ph|
			self.check_photo_in_content(ph)
		end
	end
  end

 def check_photo_in_content(ph) #делаем фотографию невидимой в основном списке фотографий сообщения и делаем видимой, если её там нет
		if content.index("#Photo#{ph.id}") != nil and content.index("#Photo#{ph.id}") != -1
			ph.set_as_hidden
		else
			ph.set_as_visible
		end  
  end

  def updater_string #Выводит информацию о последнем обновлении темы
	updater_text = ""
	if updater_id != nil
		updater = "Автором" if user_id == updater_id
		updater = "Администратором" if user_id != updater_id
		updater_text = "<p class = 'istring_m norm medium-opacity' >Тема обновлена #{updater} #{updated_at.to_s(:ru_datetime)}</p>"
	end
	return updater_text
  end
#управление содержимым end  
  def last_read_message(user) #Находит крайнее непрочитанное сообщение пользователя
	if user != nil
		last_step_in_theme = Step.find_by_part_id_and_page_id_and_entity_id_and_user_id(9, 1, self.id, user.id)
		if last_step_in_theme != nil
			step_time = last_step_in_theme.visit_time if last_step_in_theme.visit_time != nil and last_step_in_theme.visit_time != ''
			not_read_msgs = self.messages.where({:created_at => step_time..Time.now, :status_id => 1})
			if not_read_msgs != []
				if not_read_msgs.first != not_read_msgs.last
					return not_read_msgs.first 
				end
			end
		end
	end
	return nil
  end
  def clean
		self.update_attributes(:content => '',:name => '')
		self.remove_attachments_and_photos
  end
  def assign_entities_from_draft(draft) #привязка сущностей с черновика
	if draft.photos != []
		draft.photos.each do |ph|
			ph.update_attributes(:theme_id => self.id)
			check_photo_in_content(ph)
		end
	end
  end
  
  def remove_attachments_and_photos #полное удаление 
	if self.photos != []
		self.photos.each do |ph|
			ph.destroy
		end
	end
	if self.attachment_files != []
		self.attachment_files.each do |af|
			af.destroy
		end
	end
  end
  def unbind_photos
	if self.photos != []
		 self.photos.each do |pht|
			pht.update_attribute(:theme_id, nil)
		 end
	end
  end
	def unbind_attachment_files
		if self.attachment_files != []
			 self.attachment_files.each do |af|
				af.update_attribute(:theme_id, nil)
			end
		end
	end
	
	def visible_photos #Видимые фотографии
		photos.where(:visibility_status_id => 1)
	end
#управление статусами	
	def do_close(current_user) #Закрываем тему
		self.update_attribute(:status_id, 3)
		self.messages.create(:topic_id => topic_id, :content => closeThemeMessage, :user_id => current_user.id, :status_id => 1)
	end
	def do_open(current_user) #Открываем тему
		self.update_attribute(:status_id, 1)
		self.messages.create(:topic_id => topic_id, :content => openThemeMessage, :user_id => current_user.id, :status_id => 1)
	end

	def set_as_visible #перевод в статус visible тему с текущим статусом hidden
		self.update_attribute(:visibility_status_id, 1) if self.visibility_status_id != 1
	end 
	def set_as_hidden #перевод в статус visible тему с текущим статусом hidden
		self.update_attribute(:visibility_status_id, 2) if self.visibility_status_id != 2
	end
	def set_as_delete
		self.update_attribute(:status_id, 2) if self.status_id == 1 
		self.update_attribute(:status_id, 4) if self.status_id == 3
	end
	def visible_messages
		Message.find_all_by_theme_id_and_status_id(self.id, 1, :order => 'created_at ASC')
	end
	def recovery
		self.update_attribute(:status_id, 1) if self.status_id == 2 
		self.update_attribute(:status_id, 3) if self.status_id == 4
	end


#счётчик просмотров
	def views
		Step.find_all_by_part_id_and_page_id_and_entity_id(9, 1, self.id)
	end
#счётчик просмотров end
private
	def openThemeMessage
		'Тема возобновлена'
	end
	def closeThemeMessage
		'Тема закрыта'
	end
end
