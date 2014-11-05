module V1
  class FriendshipsController < ApplicationController
    before_filter :restrict_access
    # GET /friends
    # GET /friends.json
    def index
      @friendships = @current_user.friends

      render json: @friendships
    end
    # GET /pending
    # GET /pending.json
    def index_pending
      @friendships = @current_user.friends_pending

      #render text: params
      render json: @friendships
    end

    # GET /friends/1
    # GET /friends/1.json
    def show
      @friendship = @current_user.find_friendship(params[:id]).first

      if @friendship
        render json: @friendship
      else
        render json: {:error => "Friendship not found"}, status: :not_found
      end
    end

    # POST /friends
    # POST /friends.json
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
        params.require(:friendship).permit(:pending,:friend_id)
      end

      def friendship_update_params
        params.require(:friendship).permit(:pending)
      end
  end
end
