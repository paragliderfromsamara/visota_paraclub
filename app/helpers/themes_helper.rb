module ThemesHelper
	def buildThemeForm
		#отрисовывается с помощью js функции initMessageForm(msg_id)
		form_for(@formTheme, :multipart => 'true') do |f|
		"
			<div class = 'tForm'>
				<div style = 'display: none;'>#{ f.file_field :uploaded_photos, :multiple => 'true' if type != 'comment'}</div>
				<div class = 'central_field' style = 'width: 950px;'>
					<br />
					<table id = 'msg_table'>
						<tr>
							<td>
								#{ f.hidden_field :topic_id, :value => @topic.id}	
								#{ f.label :name, 'Заголовок темы'}<br />
								#{ f.text_field :name, :size => '100', :class => 't_field', :autocomplete=>'off'}	
								<div><p class = 'istring #{@name_f_color if @name_f_color != nil}' id = 'nLength'><span id = 'txtL'></span> <span class = 'err' id = 'txtMatchesErr'></span> <span id = 'txtErr'>#{@name_error if @name_error != nil}</span><span id = 'txtErrSrv'>#{@name_error if @name_error != nil}</span></p></div><br />									
								<div style = 'position: relative; z-index: 1000; width: 100%;' id = 'likebleNames'></div><br />
							</td>
						</tr>
						<tr>
							<td id = 'frm' colspan = '2'>
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
									<div class = 'central_field' style = 'width: 85%;'>
									#{ f.label :content, 'Текст темы'}<br />
									#{ f.text_area :content, :cols => '100', :rows => '7', :defaultRows => '7', :class=> 't_area', :onkeyup => 'changingTextarea(this)', :style => 'position: relative; margin-left: auto; margin-right: auto; display: block;' }
									<div><p class = 'istring #{@content_f_color if @content_f_color != nil}' id = 'cLength'><span id = 'txtL'></span> <span id = 'txtErr'>#{@content_error if @content_error != nil}</span><span id = 'txtErrSrv'>#{@content_error if @content_error != nil}</span></p></div>
									</div>
									<br />
									#{ hidden_check_box(f) }
							</td>
						</tr>
						<tr>
							<td>
								<div class='actions'><br />
									#{ f.submit @button_name, :class=>'butt' }
								</div>
								<br /><br />
							</td>
						</tr>
						<tr>
							<td id = 'formPhotos'>
								#{f.label :uploaded_photos, 'Фотографии темы'}<br />
								<div class = 'dropzone' id = 'ph_to_frm'>
								</div>
								<div id = 'uploadedPhotos'>
								</div>
								<div><p class = 'istring #{@photos_f_color if @photos_f_color != nil}' id = 'iLength'><span id = 'txtL'></span> <span id = 'txtErr'>#{@photos_error if @photos_error != nil}</span><span id = 'txtErrSrv'>#{@photos_error if @photos_error != nil}</span></p></div>
							</td>
						</tr>
					</table>
					<br />
				</div>
			</div>
			".html_safe
		end
	end
	def hidden_check_box(f)
		"#{ f.hidden_field :visibility_status_id, :value => 1}"	if is_not_authorized?  
		"<br />#{ f.label :visibility_status_id, ('<img src="/files/privacy_g.png" style = "width: 20px;float: left;"/> Скрыть от не авторизованных пользователей').html_safe} #{ f.check_box :visibility_status_id, {:class=>'check_box'}, '2', '1'}<br />" if !is_not_authorized?
	end
	def themes_table
		if @themes != []
			"
				<table class = 'v_table' id = 'themes_list'>
					<tr>
						<th id = 'first'>
							Тема
						</th>
						<th title = 'Дата создания темы'>
							Дата
						</th>
						<th>
							Автор крайнего сообщения
						</th>
						<th title = 'Дата крайнего сообщения в теме'>
							Дата
						</th>
						<th id = 'last'>
							Информация
						</th>
					</tr>
					#{build_rows}
				</table>
			"
		else
			"<p class = 'istring norm'>В данном разделе нет ни одной темы...</p>"
		end
	end
	
	def build_rows
		rows = ''
		if signed_in?
			
		end
		@themes.each do |th|
			last_msg = th.last_message
			rows += "<tbody class = 't_link' link_to = '#{theme_path(th)}' title = '#{th.name}'>"
			rows += '<tr>'
			rows += "<td id = 'first' class = 't_name'>#{truncate(th.name, :length => 50)}</td><td class = 'date'>#{my_time(th.created_at)}</td>"
			if last_msg != nil
				rows += "<td>#{last_msg.user.name}</td><td class = 'date'>#{my_time(last_msg.created_at)}</td>"
			else
				rows += "<td class = 'usr'>#{th.user.name}</td><td class = 'date'>#{my_time(th.created_at)}</td>"
			end
			rows += "<td class = 'stat' valign = 'middle' id = 'last'>#{themeInformation(th)}</td>"
			rows += '</tr>'
			rows += "</tbody>"
		end
		return rows
	end

	def themeInformation(theme)
		h = theme.statusHash
		vh = theme.vStatusHash
		v = ''
		v += "#{image_tag vh[:img], :height => '20px', :style => 'float: left;', :title => vh[:ru], :id=>'vStatusImg' } " if vh[:value] == 'hidden'
		v += "#{image_tag h[:img], :height => '20px', :style => 'float: left; padding-left: 5px;', :title => h[:ru], :id=>'statusImg' } "
		v += "<img src = '/files/answr_g.png' width = '20px' style = 'float: left; padding-left: 5px;'/><span title = 'Сообщений по теме' class = 'stat'>#{theme.visible_messages.count.to_s}</span> "
		v += "<img src = '/files/eye_g.png' width = '20px' style = 'float: left;' /><span title = 'Просмотры' class = 'stat'>#{theme.views.count}</span> "
		return v
	end
	def theme_show_block(showBut)
		html = theme_body(@theme, showBut)
		p = {
				:tContent => html, 
				:classLvl_1 => 'mainEntity', 
				:classLvl_2 => 'msgBody'
			}
		return c_box_block(p)
	end
	def theme_body(theme, showBut)
		"<table style = 'width: 100%;'>
			<tr>
				<td valign = 'middle' align = 'left' style = 'height:50px;' colspan = '2'>
					<h1>#{theme.name}</h1>
				</td>
			</tr>
			<tr>
				<td valign = 'middle' align = 'left'  style='height: 45px;'>
					#{themeInformation(theme)}
				</td>
				<td valign = 'middle' align = 'right' style='height: 45px;'>
					<p class = 'istring_m norm'>Тема создана #{my_time(theme.created_at)}</p>
				</td>
			</tr>
			<tr>
				<td valign = 'middle' align = 'left' colspan = '2'>
					<span class = 'istring_m norm'>Автор темы: </span>#{link_to theme.user.name, theme.user, :class => 'b_link_i'}
				</td>
			</tr>
			<tbody id = 'middle'>
				<tr>
				<td  colspan = '2'>
					<div class = 'central_field' style = 'width: 95%;'>
						<span id = 'content' class = 'mText'>#{theme.content_html}</span>
						<br />#{theme.updater_string}
						<br />
						#{"<br /><div class = 'central_field' style = 'width: 760px;'>#{theme_list_photos(theme)}</div>" if theme.photos != []}
						#{"<br />#{list_attachments(theme.attachment_files)}" if theme.attachment_files != []}
					</div>
				</td>
				</tr>
			</tbody>
			<tr>
				<td colspan = '2'>
					<div style = 'height: 30px;'>
						#{theme_owner_buttons if showBut == true}
					</div><br />
				</td>
			</tr>
		</table>		
		"
	end
	def theme_owner_buttons #в контроллере themes#show
		buttons_array = []
		buttons_array += [{:name => 'Новое сообщение', :access => userCanCreateMsgInTheme?(@theme), :type => 'add', :id => 'newMsgBut'}]
		buttons_array += [
							{:name => "Редактировать", :access => userCanEditTheme?(@theme), :type => 'edit', :link => "#{edit_theme_path(@theme)}", :id => 'editTheme'}
							#{:name => "Добавить фото", :access => userCanEditTheme?(@theme), :type => 'camera', :link => "#{theme_path(@theme)}/add_photos", :title => 'Добавить фотографии к теме...'},
							#{:name => "Добавить файл", :access => userCanEditTheme?(@theme), :type => 'file', :link => "#{theme_path(@theme)}/add_files", :title => 'Добавить файлы к теме...'}
						]
		#buttons_array[buttons_array.length] = {:name => "Изменить фотографии", :access => isThemeOwner?(@theme),  :link => "/edit_photos?e=th&e_id=#{@theme.id}"} if @theme.photos != [] and @theme.status != 'closed'
		buttons_array[buttons_array.length] = {:name => 'Объединить с...', :access => is_super_admin?, :type => 'merge', :link => theme_path(@theme) + "/merge_themes", :title => "Объединить с другой темой", :id => 'mergeTheme'} if @theme.merge_with == nil 
		buttons_array[buttons_array.length] = {:name => 'Закрыть тему', :access => userCanSwitchTheme?(@theme), :type => 'lock',  :link => "/themes/#{@theme.id}/theme_switcher?to_do=close", :rel => 'nofollow', :id => 'themeClose'}  if @theme.status != 'closed'
		buttons_array[buttons_array.length] = {:name => 'Открыть тему', :access => userCanSwitchTheme?(@theme), :type => 'unlock',  :link => "/themes/#{@theme.id}/theme_switcher?to_do=open", :rel => 'nofollow', :id=> 'themeOpen'} if @theme.status != 'open'
		buttons_array[buttons_array.length] = {:name => 'Удалить тему', :access => userCanSwitchTheme?(@theme), :type => 'del', :link => theme_path(@theme), :rel => 'nofollow', :data_confirm => 'Вы уверены что хотите удалить тему?', :data_method => 'delete', :id=> 'deleteTheme'}
		
		return control_buttons(buttons_array).html_safe
	end
	def add_photo_to_theme_form
		form = form_for(@theme, :action => :update, :html => {:method => :put, :multipart => true}) do |f|
				("
					<input type = 'hidden' name = 'update_type' value = 'add_photos' />
					#{f.file_field :photos, :multiple => true} #{f.submit 'Загрузить фотографии'}
				").html_safe
				end
		container = "<div class = 'g_field' id = 'toggle_add_photos' style = 'position: relative; width: 100%; display: none; z-index: 1000; top: 5px;'>#{form}</div>"		
		return container.html_safe
	end
	
	def add_attachment_to_theme_form
		form = form_for(@theme, :action => :update, :html => {:method => :put, :multipart => true}) do |f|
				("
					<input type = 'hidden' name = 'update_type' value = 'add_attachments' />
					#{f.file_field :attachment_files, :multiple => true} #{f.submit 'Загрузить вложения'}
				").html_safe
				end
		container = "<div class = 'g_field' id = 'toggle_add_attachments' style = 'position: relative; width: 100%; display: none; z-index: 1000; top: 5px;'>#{form}</div>"		
		return container.html_safe
	end
	
	def theme_errors
		@content_error = ''
		@content_f_color = ''
		@name_error = ''
		@name_f_color = ''
		if @formTheme.errors[:content] != [] and @formTheme.errors[:content] != nil
			@content_f_color = "err"
			@formTheme.errors[:content].each do |err|
				@content_error += "#{err}; <br />"
			end
		end
		if @formTheme.errors[:name] != [] and @formTheme.errors[:name] != nil
			@name_f_color = "err"
			@formTheme.errors[:name].each do |err|
				@name_error += "#{err}; <br />"
			end
		end
	end
end
