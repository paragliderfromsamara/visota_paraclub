class AdminToolsController < ApplicationController
include AdminToolsHelper  
  def hidden_entities #скрытые объекты
  	  if user_type == 'admin' or user_type == 'super_admin'
		@title = 'Скрытые объекты'
	  else
		redirect_to '/404'
	  end
  end
  
  def deleted_entities #удалённые объекты
  	  if user_type == 'admin' or user_type == 'super_admin'
		@title = 'Удалённые объекты'
	  else
		redirect_to '/404'
	  end
  end
  
  def deleted_albums #удалённые альбомы
	  if user_type == 'admin' or user_type == 'super_admin'
		@title = 'Удалённые альбомы'
	  else
		redirect_to '/404'
	  end
  end
  
  def deleted_photos #удалённые фотографии
  	  if user_type == 'admin' or user_type == 'super_admin'
		@title = 'Удалённые фотографии'
	  else
		redirect_to '/404'
	  end
  end
  
  def deleted_themes #удалённые темы
    if user_type == 'admin' or user_type == 'super_admin'
		@title = 'Удалённые темы'
	else
		redirect_to '/404'
	end
  end

  def deleted_messages #удалённые сообщения
  	  if user_type == 'admin' or user_type == 'super_admin'
		@title = 'Удалённые сообщения'
	  else
		redirect_to '/404'
	  end
  end
  
  def deleted_articles #удалённые статьи
  	  if user_type == 'admin' or user_type == 'super_admin'
		@title = 'Удалённые статьи'
	  else
		redirect_to '/404'
	  end
  end
  
  def hidden_messages #скрытые сообщения
  	  if user_type == 'admin' or user_type == 'super_admin'
		@title = 'Скрытые сообщения'
	  else
		redirect_to '/404'
	  end
  end
  
  def hidden_themes #скрытые темы
    if user_type == 'admin' or user_type == 'super_admin'
		@title = 'Скрытые темы'
	else
		redirect_to '/404'
	end
  end
  
  def hidden_albums #скрытые альбомы
	  if user_type == 'admin' or user_type == 'super_admin'
		@title = 'Скрытые альбомы'
	  else
		redirect_to '/404'
	  end
  end
  
  def hidden_photos #скрытые фотографии
	  if user_type == 'admin' or user_type == 'super_admin'
		@title = 'Скрытые фотографии'
	  else
		redirect_to '/404'
	  end
  end
  
  def hidden_articles #скрытые статьи
	  if user_type == 'admin' or user_type == 'super_admin'
		@title = 'Скрытые статьи'
	  else
		redirect_to '/404'
	  end
  end
  
  def site_images #изображения оформления сайта
  	  if user_type == 'admin' or user_type == 'super_admin'
		@title = 'Изображения оформления сайта'
	  else
		redirect_to '/404'
	  end
  end
  
  def entities_recovery
	type = params[:e]
	id = params[:id]
	if type != '' and type != nil and id != '' and id != nil
		case type
		when 'ph'
			photo = Photo.find_by_id(id)
			photo.update_attributes(:status_id => 1) if photo != nil
			redirect_to :back 
		when 'th'
			theme = Theme.find_by_id(id)
			theme.update_attributes(:status_id => 1) if theme != nil
			redirect_to :back 
		end
	end
  end
  
  def disabled_events
	if user_type == 'admin' || user_type == 'super_admin'
		@title = 'Неактивные новости'
		@events = Event.find_all_by_status_id(1)
		render "events/index.html.erb"
	else
		redirect_to '/404'
	end
  end
   
  def adaptation_to_new #Создание тем из базы данных первой версии сайта.
	if user_type == 'super_admin'
		i = 0
		@fuck = []
		fuck = []
		topics = Topic.all		
		topics.each do |topic| 
			msgsWithoutTread = [] 
			frstMsgsWithName = topic.firstMessagesWithName
			frstMsgsWithoutName = topic.firstMessagesWithoutName
			if frstMsgsWithName != []
				frstMsgsWithName.each do |msg|
					theme = Theme.find_by_name(msg.name)
					if theme == nil
						theme = Theme.create(
										:name => msg.name, 
										:content => msg.content, 
										:status_id => 1, 
										:user_id => msg.user_id, 
										:topic_id => topic.id, 
										:created_at => msg.created_at,  
										:updated_at => msg.updated_at,
										:updater_id => msg.updater_id,
										:visibility_status_id => 1,
										:last_message_date => msg.created_at
									) #Создаём новую тему на базе текущего первого сообщения
						msg.bind_child_messages_to_theme_from_first_message(theme)
						msg.bind_photos_to_theme(theme)
						msg.bind_attachments_to_theme(theme)
						msg.destroy
					else	
						msg.update_attributes(:theme_id => theme.id, :visibility_status_id => 1, :status_id => 1)
						msg.bind_child_messages_to_theme_from_first_message(theme)
					end
					theme.last_msg_upd
				end
			end
			if frstMsgsWithoutName != []
				frstMsgsWithoutName.each do |msg|
					if msg.get_tread != []
						i+=1
						theme = Theme.create(
										:name => "Обсуждение без имени #{i}", 
										:content => msg.content, 
										:status_id => 1, 
										:user_id => msg.user_id, 
										:topic_id => topic.id, 
										:created_at => msg.created_at,  
										:updated_at => msg.updated_at,
										:updater_id => msg.updater_id,
										:visibility_status_id => 1,
										:last_message_date => msg.created_at
									)  #Создаём новую тему на базе текущего первого сообщения
						msg.bind_child_messages_to_theme_from_first_message(theme)
						msg.bind_photos_to_theme(theme)
						msg.bind_attachments_to_theme(theme)
						theme.last_msg_upd
						msg.destroy
					else
						theme = Theme.find_by_name_and_topic_id('Сообщения без темы', topic.id)
						theme = Theme.create(
												:user_id => 1, 
												:name => 'Сообщения без темы', 
												:content => "Здесь собраны сообщения без темы для раздела '#{topic.name}'", 
												:topic_id => topic.id, 
												:created_at => msg.created_at, 
												:updated_at => msg.updated_at, 
												:status_id => 1,
												:visibility_status_id => 1,
												:last_message_date => msg.created_at
											 )  if theme == nil
						msg.update_attributes(:theme_id => theme.id, :visibility_status_id => 1, :status_id => 1)
						theme.last_msg_upd
					end
				end
			end
		end
		albums = PhotoAlbum.all
		if albums != []
			albums.each do |album|
				album.update_attributes(:status_id => 1, :visibility_status_id => 1)
			end
		end
		photos = Photo.all
		if photos != []
			photos.each do |photo|
				photo.update_attributes(:status_id => 1, :visibility_status_id => 1)
			end
		end
		articles = Article.all
		if articles != []
			articles.each do |article|
				article.update_attributes(:status_id => 1, :visibility_status_id => 1, :accident_date => article.created_at)
			end
		end
	else
		redirect_to '/404'
	end
  end
  
end
