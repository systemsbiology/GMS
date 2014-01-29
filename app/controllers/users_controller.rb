class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
      @users = User.all

      respond_to do |format|
         format.html # index.html.erb
          format.xml  { render :xml => @people }
          format.js
          format.json { respond_with @people }
      end

  end

  def show
    @user =  User.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @person }
      format.json { respond_with @person }
    end
  end

  private
  def user_params
    params.require(:user).permit(:login, :email, :first_name, :last_name)
  end

end
