class SessionsController < ApplicationController
  def new
	 @title = @header = 'Вход на сайт'
  end

  def create
	@title = @header = 'Вход на сайт'
    user = User.authenticate(params[:session][:name],
                             params[:session][:password])
    if user.nil?
      flash.now[:error] = "Неверное имя пользователя или пароль"
      @title = @header = 'Вход на сайт'
	  @my_notice = ('<span class = "err">Неверное имя пользователя или пароль</span>').html_safe
	  respond_to do |format|
		format.html { render 'new' }
		format.json { head :no_content }
	  end
    else
      sign_in user
	  clear_steps user
	  redirect_to root_path
    end
  end

  def destroy
	sign_out
    redirect_to root_path
  end
end
