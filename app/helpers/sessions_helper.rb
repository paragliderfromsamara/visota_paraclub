
module SessionsHelper

  def sign_in(user)
  cookies.permanent.signed[:remember_token] = [user.id, user.salt]
  self.current_user = user
  end
  
  def current_user=(user)
  @current_user = user
  
  
  end
   
  def current_user
	@current_user ||= user_from_remember_token
  end
  
  def user_type
	if current_user != nil
		if @current_user.user_group_id == 1  
			user_type = "admin"
		elsif @current_user.user_group_id == 2 
			user_type = "club_pilot"
		elsif @current_user.user_group_id == 3
			user_type = "friend"
		elsif @current_user.user_group_id == 4
			user_type = "bunned"
		elsif @current_user.user_group_id == 5
			user_type = "new_user"
		elsif @current_user.user_group_id == 6
			user_type = "manager"
		elsif @current_user.user_group_id == 7
			user_type = "deleted"
		elsif @current_user.user_group_id == 0
			user_type = "super_admin"
		end
	else
		user_type = "guest"
	end
  end

   
  private
  
    def user_from_remember_token
      User.authenticate_with_salt(*remember_token)
    end

    def remember_token
      cookies.signed[:remember_token] || [nil, nil]
    end
	
	def sign_out
    cookies.delete(:remember_token)
    self.current_user = nil
    end
	
    def signed_in?
    !current_user.nil?
    end
	
end

