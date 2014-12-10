module V1
  class GroupsController < ApplicationController
    before_filter :restrict_access
    # GET /groups
    # GET /groups.json
    api :GET, "/v1/groups", "List requesters groups"
    param :access_token, String, :required => false, :desc => "Access token of the requesting user, can be passed in the request header"
    def index
      @groups = @current_user.get_groups

      render json: @groups
    end

    # GET /groups/1
    # GET /groups/1.json
    api :GET, "/v1/groups/:id", "Show a group"
    param :access_token, String, :required => false, :desc => "Access token of the requesting user, can be passed in the request header"
    param :id, String, :required => true, :desc => "Group ID"
    def show
      @group = @current_user.get_group_by_id(params[:id])

      render json: @group
    end

    def_param_group :group do
      param :group, Hash, :action_aware => true, :required => true, :allows_nil => false do
        param :title, String, :required => true
        param :user_ids, Array, :required => true, :allows_nil => false
      end
    end

    def_param_group :group_update do
      param :group, Hash, :action_aware => true, :required => true, :allows_nil => false do
        param :title, String, :required => true
      end
    end

    # POST /groups
    # POST /groups.json
    api :POST, "/v1/groups", "Create a group"
    param :access_token, String, :required => false, :desc => "Access token of the requesting user, can be passed in the request header"
    param_group :group
    def create
      @group = @current_user.groups.new(group_create_params)

      if @group.save
        render json: @group, status: :created, location: [:v1,@group]
      else
        render json: @group.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /groups/1
    # PATCH/PUT /groups/1.json
    api :PATCH, "/v1/groups/:id", "Update a group"
    api :PUT, "/v1/groups/:id", "Update a group"
    param :access_token, String, :required => false, :desc => "Access token of the requesting user, can be passed in the request header"
    param :id, String, :required => true, :desc => "Group ID"
    param_group :group_update
    error :code => 404
    def update
      @group = @current_user.get_group_by_id(params[:id])
      if @group
        if @group.update(group_update_params)
          head :no_content
        else
          render json: @group.errors, status: :unprocessable_entity
        end
      else
        render json: {"error" => "no such group"}, status: :not_found
      end
    end

    # DELETE /groups/1
    # DELETE /groups/1.json
    api :DELETE, "/v1/groups/:id", "Destroy a group"
    param :access_token, String, :required => false, :desc => "Access token of the requesting user, can be passed in the request header"
    param :id, String, :required => true, :desc => "Group ID"
    def destroy
      @group = @current_user.get_group_by_id(params[:id])
      if @group
        @group.users.delete(@current_user)
        head :no_content
      elsif
        render json: {"error" => "You don't belong to such a group"}, status: :unprocessable_entity
      end
    end

    private

      def group_create_params
        params.require(:group).permit(:title,:user_ids => [])
      end

      def group_update_params
        params.require(:group).permit(:title)
      end
  end
end
