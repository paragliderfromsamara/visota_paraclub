module AdminToolsHelper
	def entities_control_buttons(type)
		s_id = 2 if type == 'hidden'
		s_id = 3 if type == 'deleted'
		buttons = []
		themes = Theme.find_all_by_status_id(s_id)
		messages = Message.find_all_by_status_id(s_id)
		albums = PhotoAlbum.find_all_by_status_id(s_id)
		photos = Photo.find_all_by_status_id(s_id)
		articles = Article.find_all_by_status_id(s_id)
		buttons[buttons.length] = {:name => "Темы(#{themes.count})", :access => ['super_admin', 'admin'], :type => 'b_green', :link => "/admin_tools/#{type}_themes"} if themes.count != 0
		buttons[buttons.length] = {:name => "Сообщения(#{messages.count})", :access => ['super_admin', 'admin'], :type => 'b_green', :link => "/admin_tools/#{type}_messages"} if messages.count != 0
		buttons[buttons.length] = {:name => "Альбомы(#{albums.count})", :access => ['super_admin', 'admin'], :type => 'b_green', :link => "/admin_tools/#{type}_albums"} if albums.count != 0
		buttons[buttons.length] = {:name => "Фотографии(#{photos.count})", :access => ['super_admin', 'admin'], :type => 'b_green', :link => "/admin_tools/#{type}_photos"} if photos.count != 0
		buttons[buttons.length] = {:name => "Материалы(#{articles.count})", :access => ['super_admin', 'admin'], :type => 'b_green', :link => "/admin_tools/#{type}_articles"} if articles.count != 0
		return buttons
	end
	
	def themes_list(type)
		s_id = 2 if type == 'hidden'
		s_id = 3 if type == 'deleted'
		text = 'скрытых' if type == 'hidden'
		text = 'удалённых' if type == 'deleted'
		value = "Нет #{text} тем"
		themes = Theme.find_all_by_status_id(s_id)
		if themes != []
			value = "<table><tr><th>id</th><th>Автор</th><th>Название</th><th>Раздел</th><th>Сообщений</th><th></th></tr>"
			themes.each do |theme|
				value += "<tr>
							<td align = 'center'>#{theme.id}</td>
							<td align = 'center'><span title = '#{theme.user.name}'>#{truncate(theme.user.name, :length => 60)}</span></td>
							<td align = 'center'><span title = '#{theme.name}'>#{truncate(theme.name, :length => 30)}</span></td>
							<td align = 'center'><span title = '#{theme.topic.name}'>#{truncate(theme.topic.name, :length => 60)}</span></td>
							<td align = 'center'>#{theme.messages.count}</td>
							<td align = 'center'>#{link_to 'Перейти', theme, :class => 'b_link'}</td>
						 </tr>"
			end
			value += "</table>"
		end
		return value
	end
	
	def photos_list(type)
		s_id = 2 if type == 'hidden'
		s_id = 3 if type == 'deleted'
		text = 'скрытых' if type == 'hidden'
		text = 'удалённых' if type == 'deleted'
		value = "Нет #{text} фотографий"
		photos = Photo.find_all_by_status_id(s_id)
		if photos != []
			value = "<table><tr><th>id</th><th>Изображение</th><th>Тип родителя</th><th></th><th></th></tr>"
			photos.each do |photo|
				value += "<tr>
							<td align = 'center'>#{photo.id}</td>
							<td align = 'center'>#{image_tag photo.link.thumb}</td>
							<td align = 'center'>#{photo.parent_type}</td>
							<td align = 'center'>#{link_to 'Перейти', photo, :class => 'b_link'}</td>
							<td align = 'center'>#{link_to 'Восстановить', "/admin_tools/entities_recovery?e=ph&id=#{photo.id}", :class => 'b_link'}</td>
						 </tr>"
			end
			value += "</table>"
		end
		return value
	end
	
	def do_visible_messages(messages)
		if messages != []
			messages.each do |msg|
				msg.update_attributes(:visibility_status_id => 1, :status_id => 1) if msg.visibility_status_id != 1 && msg.status_id != 1 
			end
		end
	end
end
