class Topic < ActiveRecord::Base
  attr_accessible :description, :image, :name, :image_cache
  has_many :messages
  has_many :themes
  #has_many :old_messages
  mount_uploader :image, ImageUploader
  
  def alter_image
   return '/files/undefined.png' if image == nil or image == ''
   return image if image != nil and image != ''
  end
  
  def last_active_themes(is_not_authorized)
	v_status = 1
	v_status = [1,2] if !is_not_authorized
    return self.themes.select('id, name, last_message_date, user_id, created_at').where(:status_id => [1,3], :visibility_status_id => v_status).order('last_message_date DESC').limit(4)
  end
  
  def entities_count(is_not_authorized)
	c = {:cThemes => 0, :cMessages => 0}
	v_status = 1
	v_status = [1,2] if !is_not_authorized
	c[:cThemes] = self.themes.where(:status_id => [1,3], :visibility_status_id => v_status).count
	c[:cMessages] = self.messages.where(:status_id => 1, :visibility_status_id => v_status).count
	return c
  end
  
  #Для адаптации старого форума в новый
  def firstMessages
	self.messages.where(:photo_id => nil, :video_id => nil, :first_message_id => nil).order('id ASC')
  end
 
  def firstMessagesWithoutName #Находим все первые сообщения без заголовка
	msgs = []
	frst_messages = []
	msgs += self.messages.select(:id).where(:photo_id => nil, :video_id => nil, :first_message_id => nil, :name => nil)
	msgs += self.messages.select(:id).where(:photo_id => nil, :video_id => nil, :first_message_id => nil, :name => '')
	if msgs != []
		frst_messages = Message.find_all_by_id(msgs, :order => 'id ASC')
	end
	return frst_messages 
  end
  def firstMessagesWithName #Находим все первые сообщения c заголовком
	self.firstMessages - self.firstMessagesWithoutName 
  end
  
end
