module PhotoAlbumsHelper
#album block
	def album_index_block(album, i, pathName)
		html = "
				   <table style = 'width: 100%;'>				
						<tr>
							<td align='left' valign='middle'>
								<h3>#{album.name}</h3>
							</td>
							<td align = 'right' valign='middle'>
								#{albumInformation(album)}
							</td>
						</tr>
						<tr>
							<td align = 'left' valign='middle' style = 'height:30px;'>
								<p class = 'istring_m norm medium-opacity'>
									Автор #{link_to album.user.name, album.user, :class => 'b_link_i'}
								</p>
							</td>
							<td align = 'right' valign='middle'>
								<p class = 'istring_m norm medium-opacity'>Размещён #{my_time(album.created_at)}</p>
							</td>
						</tr>
						<tr>
							<td align = 'left' valign='middle' >
								<p class = 'istring_m norm medium-opacity'>Категория #{link_to album.category_name, photo_albums_path(:c=>album.category_path), :class => 'b_link_i', :title => "Все альбомы категории #{album.category_name}"}</p>
							</td>
							<td align = 'right' valign='middle'>
								
							</td>
						</tr>
						#{"<tr><td colspan = '2' align = 'left' valign='top'><p class = 'istring_m norm' style = 'padding-top:10px; padding-bottom:10px;'>#{album.description}</p></td></tr>" if album.description != nil and album.description != ''}
						<tr>
							<td colspan = '2'>
								#{album_photos_field(album, pathName)}
								
							</td>
						</tr>
						#{bottom_album_buttons(album, pathName)}	
				   </table>
				  "
		p = {
				:tContent => html, 
				:idLvl_1 => "b_middle",
				:parity => i
			}
		v = top_album_buttons(album, pathName)
		v = (v == '')? '':"<div class = 'c_box'><div class = 'central_field' id = 'm_1000wh'>#{v}</div></div>"
		return "#{v}#{c_box_block(p)}".html_safe
	end
	def album_photos_field(album, pathName)
		value = ''
		photos = []
		if pathName == 'index'
			photos = album.index_photos
		elsif pathName == 'show'
			photos = album.visible_photos
		end
		if photos != []
			photos.each do |p|
				value += "<a href = '#{photo_path(p)}' title = '#{p.description}' alt = '#{photo_path(p)}' ><div class = 'inline-blocks inline-mini'><div class = 'central_field' style = 'width: 150px; margin-top: 7px;'>#{image_tag p.link.thumb, :width => '150px'}</div></div></a>" if pathName == 'index' 
				value += "<a href = '#{photo_path(p)}' title = '#{p.description}' alt = '#{photo_path(p)}' ><div class = 'inline-blocks inline-thumb'><div class = 'central_field' style = 'width: 250px; margin-top: 15px;'>#{image_tag p.link.thumb, :width => '250px'}</div><div style = 'width: 100px; height: 23px; position: absolute; bottom: 5px; right: 15px;'>#{photoInfo(p)}</div></div></a>" if pathName == 'show'
			end
			value = "<div class = 'central_field' style = 'width: 903px; padding-top: 10px; padding-bottom:10px;'>#{value}</div>"
		end
		return value
	end
	def top_album_buttons(album, pathName) #кнопки в верхней части блока
		v=[]
		val=''
		if pathName == 'show' and @album != nil
			v = [
				 {:name => 'К списку альбомов', :access => true, :type => 'follow', :link => "#{photo_albums_path}"}, 
				 {:name => 'Все альбомы пользователя', :access => true, :type => 'follow', :link => "/users/#{@album.user.id.to_s}/photo_albums"},
				 {:name => 'Редактировать', :access => isEntityOwner?(@album), :type => 'edit', :link => "#{edit_photo_album_path(@album)}"},	
				 {:name => 'Удалить', :access => isEntityOwner?(@album), :type => 'del', :link => photo_album_path(@album), :rel => 'nofollow', :data_confirm => 'Вы уверены что хотите удалить альбом и всё, что с ним связанно?', :data_method => 'delete'}
			]
		end
		val = "<tr><td style = 'height: 40px;' align='left' valign = 'middle' colspan = '2'>#{control_buttons(v)}</td></tr>" if v != []
		return val
	end	
	def bottom_album_buttons(album, pathName) #кнопки в нижней части блока
		v = []
		val = ''
		if pathName == 'index'
			v = [{:name => 'Перейти', :access => true, :type => 'follow', :link => "#{photo_album_path(album)}"}]
		elsif pathName == 'show' and @album != nil
			v = [{:name => 'Добавить комментарий', :access => userCanCreateMsg?, :type => 'add', :id => 'newMsgBut'}]
		end
		val = "<tr><td style = 'height: 40px;' align='left' valign = 'middle' colspan = '2'>#{control_buttons(v)}</td></tr>" if v != []
		return val
	end
	def albumInformation(album)
		v = "<img src = '/files/camera_g.png' width = '18px' style = 'float: left; padding-left: 5px;'/><span title = 'Фотографий в альбоме' class = 'stat'>#{album.visible_photos.count}</span> "
		v += "<img src = '/files/answr_g.png' width = '20px' style = 'float: left; padding-left: 5px;'/><span title = 'Комментарии' class = 'stat'>#{album.comments.count.to_s}</span> "
		v += "<img src = '/files/eye_g.png' width = '20px' style = 'float: left;' /><span title = 'Просмотры' class = 'stat'>0</span> "#{album.views.count}
		return "<div id = 'right_f'>#{v}</div>"
	end
#album block end
	def album_errors
		@name_error = ''
		@description_error = ''
		@photos_error = ''
		@name_f_color = ''
		@description_f_color = ''
		@photos_f_color = ''
		if @albumToForm.errors[:name] != nil and @albumToForm.errors[:name] != []
			@name_f_color = "err"
			@albumToForm.errors[:name].each do |err|
				@name_error += "#{err}"
			end
		end
		if @albumToForm.errors[:description] != nil and @albumToForm.errors[:description] != []
			@description_f_color = "err"
			@albumToForm.errors[:description].each do |err|
				@description_error += "#{err}"
			end
		end
		if @albumToForm.errors[:photos] != nil and @albumToForm.errors[:photos] != []
			@photos_f_color = "err"
			@albumToForm.errors[:photos].each do |err|
				@photos_error += "#{err}"
			end
		end
	end
	def initPhotoAlbumForm
		if !is_not_authorized?		
			if @albumToForm != nil
				draft = @albumToForm
			else
				draft =	current_user.album_draft
				if @albumToCreate == nil
					@albumToForm = PhotoAlbum.new
				else
					@albumToForm = @albumToCreate
				end
			end
			if action_name == 'new' || action_name == 'create'
				formName = '#new_photo_album'
				@buttName = 'Создать альбом'
			elsif action_name == 'edit' || action_name == 'update'
				formName = '.edit_photo_album'
				@buttName = 'Внести изменения'
			end
			album_errors
			@add_functions = "initAlbumForm(#{draft.id}, '#{formName}');"
		end
	end
	def albums_paths_buttons #buttons => {:name => 'Перейти', :title => "Перейти на страницу пилота", :access => ['all'], :type => 'b_green', :link => user_path(user)}
		al = PhotoAlbum.new
		link = photo_albums_path
		link = "/users/#{@user.id}/photo_albums" if @user != nil
		cur = params[:c]
		all_but = {:name => 'Все категории', :access => true, :type => 'b_grey', :link => link} 
		all_but[:selected] = true if cur == nil or cur == []
		buttons_array = [
							all_but   
						]
		al.categories.each do |c|
			if @user == nil
				cAlbums = PhotoAlbum.find_all_by_category_id_and_status_id(c[:value], 1)
			else
				cAlbums = PhotoAlbum.find_all_by_category_id_and_status_id_and_user_id(c[:value], 1, @user.id)
			end
			but = {:name => "#{c[:name]} [#{cAlbums.count}]", :access => true, :type => 'b_grey', :link => link + "?c=" +c[:path_name]}
			but[:selected] = true if cur == c[:path_name]
			buttons_array[buttons_array.length] = but
			
		end
		return buttons_in_line(buttons_array)
	end
#не актуально....
	def photo_comment_block(message, visibility)
		"<div class = 'bl_1' style = 'display: #{visibility};' id = 'm_#{message.id}'>
			<div class = 'bl_2_h'>
				<p>#{message.created_at.to_s(:ru_datetime)}</p>
			</div>
			<div class = 'bl_1_body'>
				<table style = 'width: 98%;'>
					<tr>
						#{"<td align = 'center' valign = 'top' style = 'width: 50px;'>
							<div >
								#{image_tag message.photo.link.small, :style => 'display: block; position: relative;'}
							</div>
						</td>" if message.photo != nil}
						<td align = 'left' valign = 'top'>
							#{message.user.empty_card} <hr />
							#{answer_to_msg(message)}
							<p align = 'left' id = 'content'>#{message.content_html}</p>
							<br />
							#{message.message_updater}
						</td>
					</tr>
				</table>
				
			</div>
			<div id = 'answr' class = 'central_field' style = 'width: 99%; z-index: 1000;'></div>
			<div class = 'bl_1_bottom'>
				#{buttons_in_line(comment_buttons_bottom(message))}
			</div>
		</div>"
	end
	
	def comment_buttons_bottom(message)
		arr = []
		arr[arr.length] =  {:name => 'Читать все комментарии', :access => ['all'], :type => 'b_grey', :link => photo_path(message.photo) + '#comments'} if message.photo != nil
		arr[arr.length] =  {:name => 'Ответить', :access => ['super_admin', 'admin', 'manager', 'club_pilot', 'friend'], :type => 'b_green', :onclick => 'makeAnswer(' + "#{message.id}" + ', this)', :id => 'answer_but'}
		arr[arr.length] =  {:name => 'Изменить', :access => ['super_admin', 'admin', message.user.id], :type => 'b_green', :link => "#{edit_message_path(message)}"}
		arr[arr.length] =  {:name => 'Удалить', :access => ['super_admin', 'admin'], :type => 'b_green', :link => "#"}
		return arr
	end

	def index_albums_buttons
		[	
		 {:name => 'Добавить новый альбом', :access => !is_not_authorized?, :type => 'add', :link => new_photo_album_path}
		]
	end
	def user_albums_buttons
		[
		{:name => 'К странице пользователя', :access => ['all'], :type => 'b_grey', :link => "#{user_path(@user)}"},
		{:name => 'Все фотоальбомы', :access => ['all'], :type => 'b_grey', :link => "#{photo_albums_path}"}
		]
	end

	def album_control_buttons
		[
		 {:name => 'Добавить фотографии', :access => ['super_admin', 'admin', @album.user_id], :type => 'b_green', :id => 'toggle_but'},
		 {:name => "Изменить фотографии", :access => [@album.user_id], :type => 'b_green', :link => "/edit_photos?e=pa&e_id=#{@album.id}"}
		]
	end
	def add_photo_form
		form = form_for(@album, :action => :update, :html => {:method => :put, :multipart => true}) do |f|
				("
					<input type = 'hidden' name = 'update_type' value = 'add_photos' />
					#{f.file_field :photos, :multiple => true} #{f.submit 'Загрузить фотографии'}
				").html_safe
				end
		container = "<div id = 'add_phts'>#{buttons_in_line(album_control_buttons)}<div class = 'g_field' id = 'toggle_ent' style = 'position: relative; width: 98%; display: none; z-index: 1000; top: 5px;'>#{form}</div></div>"		
		return container.html_safe
	end
	
end
