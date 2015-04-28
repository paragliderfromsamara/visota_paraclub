module MessagesHelper
	def my_message_errors
		@content_error = "" 
		@content_f_class = "norm"
		if @formMessage.errors[:content] != [] and @formMessage.errors[:content] != nil
			@content_f_color = "err"
			@formMessage.errors[:content].each do |err|
				@content_error += "#{err}<br />"
			end
		end
	end
	def message_theme_box(message, show_buttons, i) 
		p = {
				:tContent => message_body(message, show_buttons), 
				:fContent => answrToMsg(message), 
				:classLvl_1 => 'msgs', 
				:idLvl_1 => "m_#{message.id}", 
				:classLvl_2 => 'msgBody', 
				#:idLvl_2 => '', 
				:classBg => 'cWrapper', 
				:parity => i
			}
		return c_box_block(p)
	end
	def answrToMsg(m)
		return "<div class = 'answr' id = 'answr_to_#{m.id}' style='display: none;'></div>" if user_type != 'guest' and user_type != 'bunned'
	end 
	def author_string(m)
		t = ''
		if m.theme != nil
			t = 'Автор темы' if m.user == m.theme.user
		end
		if m.video != nil
			t = 'Автор видео' if m.user == m.video.user
		end
		if m.photo != nil
			t = 'Автор фото' if m.user == m.photo.user
		end
		if m.photo_album != nil
			t = 'Автор альбома' if m.user == m.photo_album.user
		end
		t = "<p class = 'istring_m medium-opacity'>#{t}</p>" if t != ''
		return t
			#{'' if message.user == message.theme.user}
	end
	def message_body(message, show_buttons)
		tread = message.get_visible_tread
		html = "
				<a name = 'msg_#{message.id}'></a>
				<table>
					<tr>
						<td valign = 'middle' align = 'left'  colspan = '2' style='height: 45px;'>
							<p class = 'istring_m norm medium-opacity'>Написано #{message.created_at.to_s(:ru_datetime)} #{answer_to_msg(message)}</p>
						</td>
					</tr>
					<tbody id = 'middle'>
						<td id = 'usr'>
							#{message_user_row(message)}
							<br />
								#{author_string(message)}
							#{("<br />#{link_to 'Редактировать фото', "/edit_photos?e=msg&e_id=#{message.id}", :class => 'b_link'}") if message.user == current_user and message.photos != []}
						</td>
						<td>
							<div class = 'central_field' style = 'width: 95%;'>
								#{message_photo(message)}
								<span align = 'left' id = 'content' class = 'mText'>#{message.content_html}</span>
								
								<br />
								#{message.message_updater}
								#{"<br /><div class = 'central_field' style = 'width: 760px;'>#{message_list_photos(message)}</div>" if message.visible_photos != []}
								#{"<br />#{list_attachments(message.attachment_files)}" if message.attachment_files != []}
							</div>
						</td>
					</tbody>
					<tr>
						<td colspan = '2' valign = 'middle'>
							<table style = 'width: 100%; height: 100%;'>
								<tr>
									<td align = 'left' valign = 'middle' style = 'width: 60%;'>
										#{control_buttons(msg_block_buttons_bottom_in_theme(message, tread.count)) if show_buttons == true and @theme != nil}
										#{control_buttons(msg_block_buttons_bottom_in_video(message, tread.count)) if show_buttons == true and @video != nil}
										#{control_buttons(msg_block_buttons_bottom_in_album(message, tread.count)) if show_buttons == true and @album != nil}
									</td>
									<td align = 'right' valign = 'middle'>
										<span  class = 'istring_m norm medium-opacity'>Ответов: #{tread.count}</span>
									</td>
								</tr> 
							</table>
						</td>
					</tr>			
				</table>		
		"
		return html
	end
	def gsub_test(text)
	   text.gsub(/\[fNum\](\n|\r)+((\d+\.\s.*(\n|\r)+)+)\[\/fNum\]/) do #\n((\d+\.\s.*\n)*)(\n)*\ \n\d+\.\s.*\n\[\/fNum\]
		c = $2
		if c != '' and c != nil 
			c = c.gsub(/(\d+)\.\s(.*)(\n|\r)/){"<li type = '1' value = #{$1}>#{$2}</li>"}
			"<ul class = 'cnt-un-num'>#{c}</ul>"
		else
			''
		end
		%{<ul class = 'cnt-un-num'>#{c}</ul>}
	  end
	end
	
	def message_photo(message)
		if message.photo != nil
			return "<div class = 'central_field' style = 'width:500px;'><p class='istring_m medium-opacity'>Комментарий к фотографии</p>#{image_tag message.photo.link, :width => '500px' if message.photo.isHorizontal?}#{image_tag message.photo.link, :height => '250px' if !message.photo.isHorizontal?}</div><br />" if message.photo != @photo 
		end
		return ''
	end
	def message_user_row(message)
		if message.user_id == nil or message.user_id == 0 and message.user_name != nil and message.user_name != ''
			return "<span class = 'istring_m norm'>#{message.user_name}</span><br />#{image_tag('/files/undefined.png', :width => '90px')}"
		elsif message.user_id != nil and message.user_id != 0
			return "#{link_to message.user.name, message.user, :class => 'b_link_i'}<br />#{image_tag(message.user.alter_avatar, :width => '90px')}"
		elsif message.user_name == nil and message.user_name == '' and message.user_id == nil or message.user_id == 0 	
			return "<span class = 'istring_m norm'>Гость</span><br />#{image_tag('/files/undefined.png', :width => '90px')}"
		end
	end
	#new_message_init
	def newMessageFormInitial(display, formClass)
		form = ''
		flag = false
		type = 'comment'
		if (@theme != nil || @photo != nil || @album != nil || @video != nil) && (user_type != 'bunned' and user_type != 'guest')
			@tmpMessage = current_user.message_draft
			if @theme != nil
				if userCanCreateMsgInTheme?(@theme)
					@alterReturnTo = theme_path(@theme)
					flag = true
					type = 'message' if @photo == nil
					type = 'comment' if @photo != nil
					if @tmpMessage.theme_id != @theme.id and @tmpMessage.topic_id != @theme.topic_id
						@tmpMessage.clean
						@tmpMessage.update_attributes(:theme_id => @theme.id, :topic_id => @topic_id)
					end
				end
			end
			if @video != nil 
				if !is_not_authorized?
					@alterReturnTo = video_path(@video)
					flag = true
					if @tmpMessage.video_id != @video.id
						@tmpMessage.clean
						@tmpMessage.update_attribute(:video_id, @video.id)
					end
				end
			end
			if @album != nil 
				if !is_not_authorized?
					flag = true
					chAlbumFlag = false
					chPhotoFlag = false
					@alterReturnTo = photo_album_path(@album)
					if @photo != nil
						@alterReturnTo = photo_path(@photo)
						chPhotoFlag = true if @tmpMessage.photo_id != @photo.id
					end
					chAlbumFlag = true if @tmpMessage.photo_album_id != @album.id
					if chAlbumFlag || chPhotoFlag
						@tmpMessage.clean
						if chAlbumFlag and chPhotoFlag
							@tmpMessage.update_attributes(:photo_id => @photo.id, :photo_album_id => @photo.photo_album_id)
						elsif chAlbumFlag and !chPhotoFlag
							@tmpMessage.update_attribute(:photo_album_id, @album.id)
						end	
					end
				end
			end
			if @message_to != nil
				flag = true
			end
		end
		flag &= userCanCreateMsg?
		if flag == true
			ent = @tmpMessage
			if @formMessage == nil
				@formMessage = Message.new
			else
				ent = @formMessage
			end
			@add_functions = (@add_functions == nil)? "initMessageForm(#{ent.id.to_s}, '#{formClass}', '#{type}');":@add_functions+"initMessageForm(#{ent.id.to_s}, '#{formClass}', '#{type}');"
			form = "<div style = 'display: #{display};' id = 'newMsgForm'>#{buildMsgForm(type)}</div>"
			p = {:tContent => form}
			return c_box_block(p)
		else
			return ''
		end
	end
	def buildMsgForm(type)
		#отрисовывается с помощью js функции initMessageForm(msg_id)
		form_for(@formMessage, :multipart => 'true') do |f|
		"
			<div class = 'mForm'>
				
				<div style = 'display: none;'>#{ f.file_field :uploaded_photos, :multiple => 'true' if type != 'comment'}</div>
				#{ hidden_field :info, :return_to_link, :value => getMsgPathLinkAfterSave}
				#{ f.hidden_field :message_id, :value => @message_to.id if @message_to != nil }
				#{ f.hidden_field :theme_id, :value => @theme.id if @theme != nil}
				#{ f.hidden_field :photo_id, :value => @photo.id if @photo != nil}
				#{ f.hidden_field :video_id, :value => @video.id if @video != nil}
				#{ f.hidden_field :photo_album_id, :value => @album.id if @album != nil}
				<div class = 'central_field' style = 'width: 950px;'>
					<br />
					<table id = 'msg_table' style = 'width: 100%;'>
						<tr>
							<td id = 'frm' valign = 'top'>
									<table id = 'formMenuTable'>
										<tr>
											<td id = 'formButtons'>
											</td>
										</tr>
										<tr>
											<td id = 'formMenus'>
											</td>
										</tr>
									</table>
									#{ f.label :content, 'Текст сообщения' if type == 'message'}#{ f.label :content, 'Комментарий' if type == 'comment'}<br />
									#{ f.text_area :content, :cols => 90, :rows => '7', :defaultRows => '7', :class=> 't_area'}
									<div><p class = 'istring #{@content_f_color if @content_f_color != nil}' id = 'cLength'><span id = 'txtL'></span> <span id = 'txtErr'>#{@content_error if @content_error != nil}</span><span id = 'txtErrSrv'>#{@content_error if @content_error != nil}</span></p></div>
								<div class='actions'>
									#{ f.submit 'Отправить', :class=>'butt' }
								</div>
								<div id = 'editorPreview' class = 'mText' style = 'position: relative; width: 100%; margin-top: 20px; margin-bottom: 20px; '>
								
								</div>
							</td>
							#{"
							<tr>

							<td id = 'formPhotos'>
								#{f.label :uploaded_photos, 'Фотографии сообщения'}<br />
								<div class = 'dropzone' id = 'ph_to_frm'>
								</div>
								<div id = 'uploadedPhotos'>
								</div>
								<div><p class = 'istring #{@photos_f_color if @photos_f_color != nil}' id = 'iLength'><span id = 'txtL'></span> <span id = 'txtErr'>#{@photos_error if @photos_error != nil}</span><span id = 'txtErrSrv'>#{@photos_error if @photos_error != nil}</span></p></div>
							</td>
							</tr>
							" if type != 'comment'}
						</tr>
					</table>
					<br />
				</div>
			</div>
			".html_safe
		end
	end
	def getMsgPathLinkAfterSave
		if @return_to == nil or @return_to == ''
			return @alterReturnTo
		else 
			return @return_to
		end
		
	end
#new_message_init end
	def answer_to_msg(message)		
		if message.message == nil
			return ""
		else
			if message.message.user != current_user
				answer_to = message.message.user.name
				if message.theme != nil
					answer_to += " (Автору темы)" if message.message.user == message.theme.user
				end
				if message.message.user != message.user and message.message.status_id == 1 
					return "<a id = 'ans_link' class = 'b_link_i' href = '#m_#{message.message.id.to_s}'>ответ пользователю #{answer_to}</a>"
				else
					return ""
				end
			else
				if message.message.user != message.user and message.message.status_id == 1 
					return "<a id = 'ans_link' class = 'b_link_i' href = '#m_#{message.message.id.to_s}'>ответил Вам</a>"
				else
					return ""
				end
			end
		end
	end
	def msg_block_buttons_bottom_in_theme(message, treadCount)
		buttons = []
		buttons += [{:name => 'Ответить', :access => userCanCreateMsgInTheme?(message.theme), :type => 'answr', :alt => message.id, :id => 'answer_but'}] if (user_type != 'bunned' and user_type != 'guest' || (user_type == 'new_user' and @theme.topic_id == 6)) if @theme.status == 'open'
		buttons += [{:name => 'К обсуждению', :access => true, :type => 'follow', :link => "#{message_path(message.id)}"}] if treadCount != 0 and @message != message
		buttons += [{:name => 'Изменить', :access => userCanEditMsg?(message), :type => 'edit', :link => "#{edit_message_path(message)}"}]
		buttons += [{:name => 'Удалить', :access => userCanDeleteMessage?(message), :type => 'del', :link => message_path(message), :rel => 'nofollow', :data_confirm => 'Вы уверены что хотите удалить сообщение?', :data_method => 'delete'}] if @theme.status == 'open'
		buttons[buttons.length] = {:name => 'Перенести сообщение', :access => is_admin?, :link => "/messages/#{message.id}/replace_message"}
		return buttons
	end
	def msg_block_buttons_bottom_in_video(message, treadCount)
		buttons = [{:name => 'Ответить', :access => !is_not_authorized?, :type => 'answr', :alt => message.id, :id => 'answer_but'}]
		buttons += [{:name => 'К обсуждению', :access => true, :type => 'follow', :link => "#{message_path(message)}"}] if treadCount != 0 and @message != message
		buttons += [
					{:name => 'Изменить', :access => false, :type => 'edit', :link => "#{edit_message_path(message)}"}, 
					{:name => 'Удалить', :access => false, :type => 'del', :link => ""}
				   ]
		return buttons
	end
	def msg_block_buttons_bottom_in_album(message, treadCount)
	    buttons = [{:name => 'Ответить', :access => !is_not_authorized?, :type => 'answr', :alt => message.id, :id => 'answer_but'}]
		buttons += [{:name => 'К обсуждению', :access => true, :type => 'follow', :link => "#{message_path(message)}"}] if treadCount != 0 and @message != message
		buttons += [
					{:name => 'Изменить', :access => false, :type => 'edit', :link => "#{edit_message_path(message)}"}, 
					{:name => 'Удалить', :access => false, :type => 'del', :link => ""}
				   ]
		return buttons
	end
	def message_panel
		link_name = 'Новое сообщение'
		link_name = 'Добавить комментарий' if controller.controller_name == "videos" or controller.controller_name == "photo_albums" or controller.controller_name == "photos"
		[
			{:name => link_name, :access => ['super_admin', 'admin', 'club_pilot', 'manager', 'friend'], :type => 'add', :id => 'toggle_msg'}
		]
	end
	
end
