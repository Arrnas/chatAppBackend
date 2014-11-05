module V1
  class GroupsController < ApplicationController
    before_filter :restrict_access
    # GET /groups
    # GET /groups.json
    def index
      @groups = @current_user.get_groups

      render json: @groups
    end

    # GET /groups/1
    # GET /groups/1.json
    def show
      @group = @current_user.get_group_by_id(params[:id])

      render json: @group
    end

    # POST /groups
    # POST /groups.json
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
