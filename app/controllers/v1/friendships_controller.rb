module V1
  class FriendshipsController < ApplicationController
    before_filter :restrict_access
    # GET /friends
    # GET /friends.json
    api :GET, "/v1/friends", "List current users friends"
    param :access_token, String, :required => false, :desc => "Access token of the requesting user, can be passed in the request header"
    def index
      @friendships = @current_user.friends

      render json: @friendships
    end
    # GET /pending
    # GET /pending.json
    api :GET, "/v1/pending", "list current users pending friends"
    param :access_token, String, :required => false, :desc => "Access token of the requesting user, can be passed in the request header"
    def index_pending
      @friendships = @current_user.friends_pending

      render json: @friendships
    end

    # GET /friends/1
    # GET /friends/1.json
    api :GET, "/v1/friends/:id", "Show a friend"
    param :access_token, String, :required => false, :desc => "Access token of the requesting user, can be passed in the request header"
    param :id, String, :required => true, :desc => "Friendship ID"
    error :code => 404
    def show
      @friendship = @current_user.find_friendship(params[:id]).first

      if @friendship
        render json: @friendship
      else
        render json: {:error => "Friendship not found"}, status: :not_found
      end
    end

    def_param_group :friendship do
      param :friendship, Hash, :action_aware => true, :required => true, :allows_nil => false do
        param :friend_id, String, :required => true
      end
    end

    def_param_group :friendship_update do
      param :friendship, Hash, :action_aware => true, :required => true, :allows_nil => false do
        param :pending, String, :required => true
      end
    end

    # POST /friends
    # POST /friends.json
    api :POST, "/v1/friends", "Create a friendship"
    param :access_token, String, :required => false, :desc => "Access token of the requesting user, can be passed in the request header"
    param_group :friendship
    error :code => 422
    def create
      @friendship = @current_user.friendships.new(friendship_create_params)

      if @friendship.save
        render json: @friendship, status: :created, location: [:v1,@friendship]
      else
        render json: @friendship.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /friends/1
    # PATCH/PUT /friends/1.json
    api :PATCH, "/v1/friends/:id", "Update a friendship"
    api :PUT, "/v1/friends/:id", "Update a friendship"
    param :access_token, String, :required => false, :desc => "Access token of the requesting user, can be passed in the request header"
    param :id, String, :required => true, :desc => "Friendship ID"
    param_group :friendship_update
    error :code => 404
    error :code => 422
    def update
      @friendship = @current_user.find_pending_friendship(params[:id]).first
      if @friendship
        if @friendship.update(friendship_update_params)
          head :no_content
        else
          render json: @friendship.errors, status: :unprocessable_entity
        end
      else
        render json: {:error => "Pending friendship not found"}, status: :not_found
      end
    end

    # DELETE /friends/1
    # DELETE /friends/1.json
    api :DELETE, "/v1/friends/:id", "Destroy a friendship"
    param :access_token, String, :required => false, :desc => "Access token of the requesting user, can be passed in the request header"
    param :id, String, :required => true, :desc => "Friendship ID"
    error :code => 404
    def destroy
      @friendship = @current_user.find_friendship(params[:id]).first
      if @friendship
        @friendship.destroy
        head :no_content
      else
        render json: {:error => "Friendship not found"}, status: :not_found
      end
    end

    private

      def friendship_create_params
        params.require(:friendship).permit(:friend_id)
      end

      def friendship_update_params
        params.require(:friendship).permit(:pending)
      end
  end
end
