module OldMessagesHelper
	#Запись старых сообщений в базу из Файла
	def put_old_messages
		text = IO.read(Rails.root.join('public/files', 'guest_book'))
		i = -1
		begin 
			i += 1
			name = extract_from_tag(text, "user_#{i.to_s}")
			date = extract_from_tag(text, "date_#{i.to_s}")
			content = extract_from_tag(text, "content_#{i.to_s}")
			name.strip!
			date.strip!
			content.strip!
			old_message = OldMessage.create(:user_name => name, :content => content, :created_when => date)
		end until(i == 2054)
	end
	  #Функция извлечения содержимого из тегов с типа [tag_name]tag_content[/tag_name]
	def extract_from_tag(text, tag_name)	
		regex = /\[#{tag_name}](.+)\[\/#{tag_name}]/
		content = ''
		text.gsub(regex) do |match|
			content = $1
		end
		return content
	end
	
	def old_message_box(message, i) 
			html = "
					<a name = 'msg_#{message.id}'></a>
					<table>
						<tr>
							<td valign = 'middle' align = 'left'  colspan = '2' style='height: 45px;'>
								<p class = 'istring_m norm medium-opacity'>Написано #{message.created_when.to_s(:ru_datetime)}</p>
							</td>
						</tr>
						<tbody id = 'middle'>
							<td id = 'usr'>
								#{old_message_user_row(message)}
							</td>
							<td>
								<div class = 'central_field' style = 'width: 95%;'>
									<span align = 'left' id = 'content' class = 'mText'>#{message.content_html}</span>
								</div>
							</td>
						</tbody>
						<tr>
							<td colspan = '2' valign = 'middle'>
								<table style = 'width: 100%; height: 100%;'>
									<tr>
										<td align = 'left' valign = 'middle' style = 'width: 60%;'>
											#{control_buttons(old_msg_block_buttons_bottom(message))}
										</td>
									</tr>
								</table>
							</td>
						</tr>			
					</table>	
				"
		p = {
				:tContent => html,  
				:classLvl_1 => 'msgs', 
				:classLvl_2 => 'msgBody', 
				:parity => i
			}
		return c_box_block(p)
	end

	def old_msg_block_buttons_bottom(message)
		[
		 {:name => 'Изменить', :access => is_admin?, :type => 'edit', :link => "#{edit_old_message_path(message)}"}, 
		 {:name => 'Удалить', :access => is_admin?, :type => 'del', :link => "#{edit_old_message_path(message)}"}
		]
	end
	def old_message_user_row(message)
		if message.user_id == nil or message.user_id == 0 and message.user_name != nil and message.user_name != ''
			return "<span class = 'istring_m norm'>#{message.user_name}</span><br />#{image_tag('/files/undefined.png', :width => '90px')}"
		elsif message.user_id != nil and message.user_id != 0
			return "#{link_to message.user.name, message.user, :class => 'b_link_i'}<br />#{image_tag(message.user.alter_avatar, :width => '90px')}"
		elsif message.user_name == nil and message.user_name == '' and message.user_id == nil or message.user_id == 0 	
			return "<span class = 'istring_m norm'>Гость</span><br />#{image_tag('/files/undefined.png', :width => '90px')}"
		end
	end
end
