module V1
  class UsersController < ApplicationController
    before_filter :restrict_access, except: :create
    # GET /users
    # GET /users.json
    def index
      show_user @current_user
    end

    # GET /users/1
    # GET /users/1.json
    def show
      @user = User.find(params[:id])
      if @user
        show_user @user
      else
        render json: { "error" => "user not found"}, status: :not_found
      end
    end

    # POST /users
    # POST /users.json
    def create
      @user = User.new(user_params)

      if @user.save
        render json: @user, status: :created, location: [:v1,@user]
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /profile
    # PATCH/PUT /profile.json
    def update
      @user = @current_user
      if @user.update(user_params)
        head :no_content
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    private

      def show_user(user)
        render json: user.as_json(except: [:password_digest, :access_token]), status:200
      end

      def user_params
        params.require(:user).permit(:email,:username,:password,:password_confirmation,:deviceid)
      end
  end
end
