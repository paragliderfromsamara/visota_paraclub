module EventsHelper
	def event_index_item(event, i) #Миниатюра в списке новостей  
    html = "<br />
						<h4>#{event.title}</h4>
            <br />
							<table style = 'width: 99%;'>
								<tr>
									#{"<td>#{event.alter_photo('thumb')}</td>" if event.alter_photo('thumb') != nil}
									<td valign = 'top' align = 'left' style = 'min-width: 700px;'>
                    <span class = 'mText' id = 'content'>
                      <p>#{truncate(event.alter_content, :length => 500)}</p>
                    </span>
                  </td>
								</tr>
							</table>
						#{control_buttons(event_index_buttons(event))}
				"
    		p = {
    				:tContent => html, 
    				:idLvl_2 => "m_1000wh", 
    				:parity => i
    			}
          return c_box_block(p)
	end
	
	def event_index_blocks #Построение списка новостей
		result = 'Нет ни одной новости'
		if @events != [] and @events != nil
			result = ''
		 @events.each do |event|
				#result += event_index_item(event)
			end
		end
		return result
	end
	
	def event_show_block
		"
			<h2>#{@event.title}</h2>
			<hr />
			<span class = 'article_content'>#{@event.content_html}</span>
			#{event_show_photos}
		"
	end
	
	def event_manage_buttons(event)
		[
			{:name => 'Изменить', :access => userCanEditEvent?(event), :type => 'edit', :link => edit_event_path(event)},
			{:name => 'Удалить', :access => userCanEditEvent?(event), :type => 'del', :link => event_path(event), :rel => 'nofollow', :data_confirm => 'Вы уверены что хотите удалить новость???', :data_method => 'delete'}
		]
	end
	def event_index_buttons(event)
		[{:name => 'Перейти', :access => true, :type => 'follow', :link => event.link_to}] + event_manage_buttons(event) 
	end
	def event_show_buttons
		val = [{:name => 'К списку новостей', :access => ['all'], :type => 'b_green', :link => events_path}] + event_manage_buttons(@event)
		val[val.length] = {:name => 'Редактировать фотографии', :access => ['super_admin', 'admin', 'manager'], :type => 'b_blue', :link => "/edit_photos?e=ev&e_id=#{@event.id}"} if @event.photos != []
		return val
	end
	def add_new_event
		control_buttons([{:name => 'Добавить новость', :access => userCanCreateEvent?, :type => 'add', :link => new_event_path}]).html_safe
	end
	
	def event_show_photos
		photos = ''
		if @event.photos != []
			photos += '<br /><br />'
			@event.photos.drop(1).each do |photo|
				photos += "#{light_box_event_photo_block(photo, photo.link.thumb, '')}" if photo.status_id != 2 and photo.status_id != 3
			end
		end
		return photos
	end
	def light_box_event_photo_block(photo, link, style)
		"
			<a data-lightbox='event_#{ @event.id.to_s }' href = '#{ photo.link }' title = '#{photo.description}' ><img src = '#{link}' #{style} class = 'album_thumb_photo'/></a>
			
		"#<span id = 'album_#{ photo.photo_album.id.to_s }_#{i}' style = 'display: none;'><a class = 'b_link' href = '#{photo_path(photo)}'>Комментарии</a></span>
	end
	
	def last_news
		text = "Нет ни одной новости"
		if @events != nil and @events != [] 
			text = "<br />"
			@events.each do |event|
				text += "<div id = 'last_event' class = 'central_field' style = 'width: 100%;'>#{my_time(event.post_date)} <b>#{truncate(event.title, :length => 50)}</b><br />"
				text += "#{event.alter_photo('small') if event.alter_photo('small') != nil}#{event.alter_content}<br />#{link_to 'Перейти', event.link_to, :class => 'b_link'}"
				text += "<hr /></div>"
			end
		end
		return text
	end
end
