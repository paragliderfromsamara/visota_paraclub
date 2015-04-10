module TopicsHelper
	
	def index_topic_buttons(topic)
		[
		 {:name => 'Перейти в раздел', :access => true, :link => "#{topic_path(topic)}", :type => 'follow', :id => 'showTopic' },
		 {:name => "Добавить тему в раздел \"#{topic.name}\"", :access => userCreateThemeInTopic?(topic), :type => 'add', :link => "#{new_theme_path(:t => topic.id)}", :id => 'newTheme'}, 
		 {:name => 'Редактировать', :access => is_super_admin?, :type => 'edit', :link => "#{edit_topic_path(topic)}", :id => 'editTopic'}
		]
	end
	def admin_index_topic_buttons
		"#{control_buttons([{:name => 'Новый раздел', :access => is_super_admin?, :type => 'add', :link => "#{new_topic_path}", :id => 'newTopic'}])}"
	end
	def show_topic_buttons(topic)
		[
		 {:name => "Добавить тему", :access => userCreateThemeInTopic?(topic), :type => 'add', :link => "#{new_theme_path(:t => topic.id)}", :id => 'newTheme'}, 
		]
	end
	def visota_life_panel

		v = {:name => "Опросы", :access => true, :type => 'grey', :link => votes_path}
	#	m = {:name => "Архив сообщений с para.saminfo.ru", :access => true, :type => 'grey', :link => old_messages_path}
	#	m[:selected] = true if controller.controller_name == 'old_messages'
		b = [v]
		return b
	end
end
