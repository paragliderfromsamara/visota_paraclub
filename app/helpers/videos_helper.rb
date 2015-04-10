module VideosHelper
	def index_videos_buttons
		[	
		 {:name => 'Добавить видео', :access => !is_not_authorized?, :type => 'add', :link => "#new", :id => 'toggle_but'}
		]		
	end
	def user_videos_buttons
		[
		{:name => 'К странице пользователя', :access => true, :type => 'follow', :link => "#{user_path(@user)}"},
		{:name => 'Все видео', :access => true, :type => 'follow', :link => "#{videos_path}"}
		]
	end
	def top_video_buttons
		[
		 {:name => 'К списку видео', :access => true, :type => 'follow', :link => "#{videos_path}"}, 
		 {:name => 'Все видео пользователя', :access => true, :type => 'follow', :link => "/users/#{@video.user.id.to_s}/videos"} 
		]
	end
	def bottom_video_buttons
		[
		 {:name => 'Добавить комментарий', :access => !is_not_authorized?, :type => 'add', :id => 'newMsgBut'},
		 {:name => 'Редактировать', :access => ['super_admin', 'admin', @video.user_id], :type => 'edit', :link => "#{video_path(:id => @video.id, :tab => 'edit')}"},
		 {:name => 'Удалить', :access => ['super_admin', 'admin'], :type => 'del', :link => "#{video_path(@video)}", :data_confirm => 'Вы уверены что хотите удалить данное видео?', :data_method => 'delete', :rel => 'nofollow'}
		]
	end
	def videoInformation(video)
		#h = theme.statusHash
		#v = "#{image_tag h[:img], :height => '20px', :style => 'float: left;', :title => h[:ru] } "
		v = "<img src = '/files/answr_g.png' width = '20px' style = 'float: left; padding-left: 5px;'/><span title = 'Комментарии' class = 'stat'>#{video.visible_messages.count.to_s}</span> "
		v += "<img src = '/files/eye_g.png' width = '20px' style = 'float: left;' /><span title = 'Просмотры' class = 'stat'>0</span> "
		return v
	end
	def video_show_block
		html = "
				<br />	
				
				<p id='notice'>#{ notice }</p>
				<table style = 'width: 100%'>
					<tr>
						<td valign = 'middle' align = 'left' style = 'height:50px;' colspan = '2'>
							<h1>#{ @video.alter_name }</h1>
						</td>
					</tr>
					<tr>
						<td valign = 'middle' align = 'left'  style='height: 30px;'>
							#{ videoInformation(@video) }
						</td>
						<td valign = 'middle' align = 'right' style='height: 30px;'>
								<span class = 'istring_m norm medium-opacity'>Видео опубликовано #{ my_time(@video.created_at) }</span>
						</td>
					</tr>
					<tr>
						<td align = 'left' valign = 'middle' colspan = '2'>
							<span class = 'istring_m norm'>Категория</span> #{ link_to @video.category_name, videos_path(:c => @video.category[:path_name]), :class => 'b_link_i' }
						</td>
					</tr>
					<tr>
						<td valign = 'middle' align = 'left' colspan = '2'>
							<span class = 'istring_m norm'>Опубликовал</span> #{ link_to @video.user.name, @video.user, :class => 'b_link_i' }
						</td>
					</tr>			
					<tr>
						<td valign = 'middle' colspan = '2' style = 'height: 550px;'>
							<div  class = 'central_field' style = 'width: 640px;'>
								#{ @video.link_html }
							</div>
						</td>	
					</tr>
					<tr>
						<td valign = 'middle' align = 'left' colspan = '2' style = 'height: 40px;'>
							#{ control_buttons(bottom_video_buttons) }
						</td>	
					</tr>
				</table>"
		p = {
				:tContent => html, 
				:classLvl_1 => 'mainEntity',  
				:classLvl_2 => 'msgBody'
			}
		return "<div class = 'c_box'><div class = 'central_field msgBody'>#{control_buttons(top_video_buttons).html_safe}</div></div>#{c_box_block(p)}"
	end
	
	def video_index_block(video)
		"
			<div class = 'video_thumb' >
							<div>
								#{video.mini_link_html}
							</div>
							<div style = 'position: relative;'>
								<div class = 'video_thumb_background'></div>
								<table class = 'video_thumb_table'>
									<tr>
										<td style = 'width: 80px' align = 'right'>
											<p class='istring_m norm medium-opacity' style = 'padding-left: 4px;'>Автор:</p>
										</td>
										<td style = 'width: 170px' >
											#{link_to video.user.name, video.user, :class => 'b_link_i', :style => 'font-size: 12px;'}
										</td>
									</tr>
									<tr>
										<td style = 'width: 80px;' align = 'right'>
											<p class='istring_m norm medium-opacity' style = 'padding-left: 4px;'>Категория:</p>
										</td>
										<td style = 'width: 170px' >
											#{link_to video.category[:name], videos_path(:category => video.category[:path_name] ), :class => 'b_link_i', :style => 'font-size: 12px;', :title => "Смотреть все альбомы категории #{video.category[:name]}"}
										</td>
									</tr>
									<tr>
										<td align = 'right' style = 'height: 25px;'>
												#{control_buttons([{:link => video_path(video), :access => true, :type=> 'follow', :name=> 'Перейти'}])}
										</td>
										<td align = 'right'>
											<span title = 'Комментарии'>#{image_tag('/files/answr_g.png', :width => '20px', :valign => 'bottom')} <span class='istring_m norm medium-opacity'>#{video.messages.where(:status_id => 1).count.to_s}</span></span>
										</td>
									</tr>
								</table>
							</div>
						</div>
		"
	end
	def video_category_part(category)
		videos = Video.find_all_by_category_id(category[:value], :order => 'created_at DESC')
		part = ''
		if videos != []
			videos_block = ''
			i = 0
			videos.each do |video|
				i += 1
				videos_block += video_index_block(video)
				break if i == 6  
			end
			part = "
					<div class = 'mono_c'>
					<div class = 'central_field' style = 'width: 98%;'><span class = 'flow_b_str'>#{category[:name]}</span> #{'(' + link_to('Смотреть все', videos_path(:category => category[:path_name]), :class => 'b_link') + ')' if videos.count > 6}</div>
					<hr />
						<div class = 'central_field' style = 'width: 1000px;'>
							#{videos_block}
						</div>
					</div>
					<br />
				   "
		end
		return part.html_safe
	end
	
	def video_errors
		@name_error = ''
		@link_error = ''
		@description_error = ''
		@name_f_color = ''
		@link_f_color = ''
		@description_f_color = ''
		if @video.errors[:name] != nil and @video.errors[:name] != []
			@name_f_color = "style = 'background-color: red; color: white;'"
			@video.errors[:name].each do |err|
				@name_error += "<span style = 'color: white;  padding-left: 5px;'>#{err}</span><br />"
			end
		end
		if @video.errors[:link] != nil and @video.errors[:link] != []
			@link_f_color = "style = 'background-color: red; color: white;'"
			@video.errors[:link].each do |err|
				@link_error += "<span style = 'color: white;'>#{err}</span><br />"
			end
		end
		if @video.errors[:description] != nil and @video.errors[:description] != []
			@description_f_color = "style = 'background-color: red; color: white;'"
			@video.errors[:description].each do |err|
				@description_error += "<span style = 'color: white;'>#{err}</span><br />"
			end
		end
	end
	def videos_paths_buttons #buttons => {:name => 'Перейти', :title => "Перейти на страницу пилота", :access => ['all'], :type => 'b_green', :link => user_path(user)}
		v = Video.new
		link = videos_path
		link = "/users/#{@user.id.to_s}/videos" if @user != nil
		
		cur = params[:c]
		all_but = {:name => 'Все категории', :access => true, :type => 'b_grey', :link => link} 
		all_but[:selected] = true if cur == nil or cur == []
		buttons_array = [
							all_but   
						]
		v.categories.each do |c|
			categoryVideos = Video.find_all_by_category_id(c[:value]) if @user == nil
			categoryVideos = Video.find_all_by_category_id_and_user_id(c[:value], @user.id) if @user != nil
			but = {:name => "#{c[:name]} [#{categoryVideos.count}]", :access => true, :type => 'b_grey', :link => link+"?c=#{c[:path_name]}"}
			but[:selected] = true if cur == c[:path_name]
			buttons_array[buttons_array.length] = but
		end
		return buttons_in_line(buttons_array)
	end	

end
