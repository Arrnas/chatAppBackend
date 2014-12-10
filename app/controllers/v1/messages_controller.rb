module V1
  class MessagesController < ApplicationController
    before_filter :restrict_access
    # GET /messages
    # GET /messages.json
    # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
    api :GET, "/v1/groups/:group_id/messages", "List messages"
    param :access_token, String, :required => false, :desc => "Access token of the requesting user, can be passed in the request header"
    param :group_id, String, :required => true
    error :code => 404
    def index
      @group = @current_user.get_group_by_id(params[:group_id])
      if @group
        @messages = @group.messages
        render json: @messages
      else
        render json: {"error" => "No such group"}, status: :not_found
      end
    end

    # GET /messages/1
    # GET /messages/1.json
    api :GET, "/v1/messages/:id", "Show a message"
    param :access_token, String, :required => false, :desc => "Access token of the requesting user, can be passed in the request header"
    param :id, String, :required => true, :desc => "Message ID"
    def show
      @message = Message.find(params[:id])

      render json: @message
    end

    def_param_group :message do
      param :message, Hash, :action_aware => true, :required => true, :allows_nil => false do
        param :message_body, String, :required => true
      end
    end

    # POST /messages
    # POST /messages.json
    api :POST, "/v1/groups/:group_id/messages", "Create a message"
    param :access_token, String, :required => false, :desc => "Access token of the requesting user, can be passed in the request header"
    param :group_id, String, :required => true
    param_group :message
    def create
      @group = @current_user.get_group_by_id(params[:group_id])
      if @group
        @message = @group.messages.new(message_create_params)
        @message.author = @current_user
        @message.timestamp = DateTime.now
        if @message.save
          render json: @message, status: :created, location: [:v1,@message]
        else
          render json: @message.errors, status: :unprocessable_entity
        end
      else
        render json: {"error" => "No such group"}, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /messages/1
    # PATCH/PUT /messages/1.json
    api :PATCH, "/v1/messages/:id", "Update a message"
    api :PUT, "/v1/messages/:id", "Update a message"
    param :access_token, String, :required => false, :desc => "Access token of the requesting user, can be passed in the request header"
    param :id, String, :required => true, :desc => "Message ID"
    def update
      @message = Message.find(params[:id])

      if @message.update(message_update_params)
        head :no_content
      else
        render json: @message.errors, status: :unprocessable_entity
      end
    end

    # DELETE /messages/1
    # DELETE /messages/1.json
    api :DELETE, "/v1/messages/:id", "Destroy a message"
    param :access_token, String, :required => false, :desc => "Access token of the requesting user, can be passed in the request header"
    param :id, String, :required => true, :desc => "Message ID"
    def destroy
      @message = Message.find(params[:id])
      if @message && @message.author == @current_user
        @message.destroy
        head :no_content
      else
        render json: {"error"=>"message not found"}, status: :not_found
      end
    end

    private

      def message_create_params
        params.require(:message).permit(:message_body)
      end

      def message_update_params
        params.require(:message).permit(:message_body)
      end
  end
end
