class Vote < ActiveRecord::Base
  #при переносе заменить в бд имена столбцов title на name, privat_flag на visibility_status_id
  attr_accessible :user_id, :message_id, :title, :content, :status_id, :start_date, :end_date, :vote_type_id, :privat_flag, :vote_values
  belongs_to :user
  has_many :vote_values, :dependent => :delete_all
  has_many :voices, :dependent  => :delete_all
  belongs_to :message
 
  
  validates :content, :presence => {:message => "Поле 'Вопрос' не должно быть пустым"},
				      :length => { :maximum => 500, :message => "Название не может быть длиннее 500-ти знаков"}
  
  validate :validation_vote_values
  
  def validation_vote_values
	
  end
  def name 
	if title == nil or title == ''
		content
	else
		title
	end
  end
  def vote_values=(attrs)
	attrs.each {|attr| self.vote_values.build(:value => attr[1]) if attr[1].strip != ''}
  end
end
