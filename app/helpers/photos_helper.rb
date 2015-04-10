module PhotosHelper
	def light_box_photo_block(photo)
		"
			<a href = '#{photo_path(photo)}' title = '#{photo.description}' >#{image_tag photo.link.thumb, :class => 'album_thumb_photo'}</a>
			
		"#<span id = 'album_#{ photo.photo_album.id.to_s }_#{i}' style = 'display: none;'><a class = 'b_link' href = '#{photo_path(photo)}'>Комментарии</a></span>
	end
	
	def photo_pagination 
		cur_index = @photos.index(@photo) #Текущий элемент
		phsCount = @photos.count #Номер последнего элемента
		max_number_in_line = 7 #Максимальное количесво номеров в ряд (ДОЛЖНО БЫТЬ НЕЧЁТНЫМ!!!)
		val = ''
		@f='none'
		@l='none'
		@c='none'
		offset = (max_number_in_line-1)/2
		if phsCount < max_number_in_line
			i = 0
			@photos.each do |p|
				if i == cur_index
					val += "<div class = 'ph-paginate ph-cur' style = 'background-image:url(\"#{p.link.thumb}\");' ></div>"
				else
					val += "<div class='ph-paginate' link_to='#{photo_path(p)}' style = 'background-image:url(\"#{p.link.thumb}\");'></div>"
				end
				i += 1	
			end
		else
			fVisible = 0
			lVisible = 0
			if (cur_index + offset) > (phsCount-1)
				fVisible = phsCount-max_number_in_line
				lVisible = phsCount-1
			elsif(cur_index - offset) < 0
				fVisible = 0
				lVisible = max_number_in_line-1
			elsif !((cur_index + offset) > (phsCount-1)) && !((cur_index - offset) < 0)
				fVisible = cur_index - offset
				lVisible = cur_index + offset
			end
			@f=fVisible
			@l=lVisible
			@c= cur_index
			i = 0
			@photos.each do |p|
				if i == cur_index
					val += "<div class = 'ph-paginate ph-cur' style = 'background-image:url(\"#{p.link.thumb}\");' ></div>"
				elsif !(i<fVisible) and !(i>lVisible) 
					val += "<div class='ph-paginate' link_to='#{photo_path(p)}' style = 'background-image:url(\"#{p.link.thumb}\");'></div>"
				else
					val += "<div class='ph-paginate ph-h' link_to='#{photo_path(p)}' style = 'background-image:url(\"#{p.link.thumb}\");'></div>"
				end
				i+=1
			end
		end
		return "#{val}"
	end
	
	def make_numbers_string(start_index, end_index, cur_index)
		value = ''
		i = 0
		@photos.each do |p|
			if i == cur_index
				value += "#{image_tag(@photos[i].link.thumb, :class => 'ph-paginate ph-cur')}"
			elsif !(i<start_index) and !(i>end_index) and i != cur_index
				value += "<a href = '#{photo_path(p)}'>#{image_tag(p.link.thumb, :class => 'ph-paginate ph-cur')}</a>"
			elsif (i<start_index) or (i>end_index)	
				value += "<a href = '#{photo_path(p)}'>#{image_tag(p.link.thumb, :class => 'ph-paginate ph-cur ph-h')}</a>"
			end
			i += 1
		end
		return value
	end
	
	def photo_nav_bar
		value = ''
		#value += "#{link_to(image_tag(@photo.user.alter_avatar_thumb), @photo.user, :title => 'Перейти к странице пользователя ' + @photo.user.name)}" if @photo.user != nil
		value += "#{link_to 'К альбому', @photo.photo_album} <span style = 'font-family: Tahoma;'>|</span> #{link_to('Все альбомы', photo_albums_path)}" if @photo.photo_album != nil
		return value
	end
	
	def photo_info
		value = ''
		value += "<tr><td align = 'left' valign = 'middle'><span class = 'istring_m norm'>Фото разместил</span> #{link_to @photo.user.name, @photo.user, :class=>'b_link_i'}</td></tr>" if @photo.user != nil
		value += "<tr><td align = 'left' valign = 'middle'><span class = 'istring_m norm'>Размещено #{@photo.parent[:published_in]}</span> #{link_to(@photo.parent[:parent_name], @photo.parent[:parent_link], :class => 'b_link_i')}</td></tr>" 
		return "<table style = 'width: 98%; font-size: 14pt;'>#{value}</table>"
	end
	def photoInfo(photo)
		v = "<img src = '/files/answr_g.png' width = '17px' style = 'float: left; padding-left: 7px;'/><span title = 'Комментарии' class = 'stat'>#{photo.comments.count.to_s}</span> "
		v += "<img src = '/files/eye_g.png' width = '20px' style = 'float: left;  padding-left: 7px;' /><span title = 'Просмотры' class = 'stat'>#{photo.views.count}</span> "#{album.views.count}
		return "<div class = 'medium-opacity' id = 'right_f'>#{v}</div>"
	end
	def photo_comment_button
		control_buttons([{:name => 'Добавить комментарий', :access => userCanCreateMsg?, :type => 'add', :id => 'newMsgBut'}])
	end
	
	def message_list_photos(msg)
		value = ''
		phts = msg.visible_photos
		if phts != []
			phts.each do |photo|
				value += "<a href = '#{photo_path(photo)}' title = '#{photo.description}' alt = '#{photo_path(photo)}' ><div class = 'inline-blocks inline-thumb'><div class = 'central_field' style = 'width: 250px; margin-top: 15px;'>#{image_tag photo.link.thumb, :width => '250px'}</div><div style = 'width: 100px; height: 23px; position: absolute; bottom: 5px; right: 15px;'>#{photoInfo(photo)}</div></div></a>"
			end
		end
		return value
	end
	
	def theme_list_photos(th)
		value = ''
		phts = th.visible_photos
		if phts != []
			phts.each do |photo|
				value += "<a href = '#{photo_path(photo)}' title = '#{photo.description}' alt = '#{photo_path(photo)}' ><div class = 'inline-blocks inline-thumb'><div class = 'central_field' style = 'width: 250px; margin-top: 15px;'>#{image_tag photo.link.thumb, :width => '250px'}</div><div style = 'width: 100px; height: 23px; position: absolute; bottom: 5px; right: 15px;'>#{photoInfo(photo)}</div></div></a>"
			end
		end
		return value
	end
	def article_list_photos(ar)
		value = ''
		phts = ar.visible_photos
		if phts != []
			phts.each do |photo|
				value += "<a href = '#{photo_path(photo)}' title = '#{photo.description}' alt = '#{photo_path(photo)}' ><div class = 'inline-blocks inline-thumb'><div class = 'central_field' style = 'width: 250px; margin-top: 15px;'>#{image_tag photo.link.thumb, :width => '250px'}</div><div style = 'width: 100px; height: 23px; position: absolute; bottom: 5px; right: 15px;'>#{photoInfo(photo)}</div></div></a>"
			end
		end
		return value
	end
end
