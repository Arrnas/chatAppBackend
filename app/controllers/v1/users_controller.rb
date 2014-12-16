module V1
  class UsersController < ApplicationController
    before_filter :restrict_access, except: :create
    # GET /users
    # GET /users.json
    api :GET, "/v1/profile", "List users"
    api :GET, "/v1/users", "List users"
    param :access_token, String, :required => false, :desc => "Access token of the requesting user, can be passed in the request header"
    error :code => 401
    def index
      show_user @current_user
    end

    # GET /users/1
    # GET /users/1.json
    api :GET, "/v1/users/:id", "Show an user"
    param :access_token, String, :required => false, :desc => "Access token of the requesting user, can be passed in the request header"
    param :id, String, :required => true, :desc => "User ID"
    error :code => 404
    def show
      @user = User.find(params[:id])
      if @user
        show_user @user
      else
        render json: { "error" => "user not found"}, status: :not_found
      end
    end

    # GET /users/asdf
    # GET /users/asdf.json
    api :GET, "/v1/users/:name", "Show an user"
    param :access_token, String, :required => false, :desc => "Access token of the requesting user, can be passed in the request header"
    param :name, String, :required => true, :desc => "User name"
    error :code => 404
    def showUser
      @user = User.find_by_username(params[:name])
      if @user
        show_user @user
      else
        render json: { "error" => "user not found"}, status: :not_found
      end
    end


    def_param_group :user do
      param :user, Hash, :action_aware => true, :required => true, :allows_nil => false do
        param :username, String, :required => true
        param :password, String, :required => true
        param :password_confirmation, String, :required => false, :allows_nil => false
        param :deviceid, String, :required => true
        param :email, String, :required => true
      end
    end


    # POST /users
    # POST /users.json
    api :POST, "/v1/users", "Create a user"
    param_group :user
    error :code => 422
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
    api :PATCH, "/v1/profile", "Update a user"
    api :PUT, "/v1/profile", "Update a user"
    param :access_token, String, :required => false, :desc => "Access token of the requesting user, can be passed in the request header"
    param_group :user
    error :code => 422
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
