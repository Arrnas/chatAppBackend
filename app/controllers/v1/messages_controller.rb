module V1
  class MessagesController < ApplicationController
    before_filter :restrict_access
    # GET /messages
    # GET /messages.json
    def index
      @group = @current_user.get_group_by_id(params[:group_id])
      if @group
        if params[:last] && params[:last].is_a?(Numeric)
          last = params[:last]
        else
          last = 20
        end
        if @group.messages.count > last
          @messages = @group.messages.drop(last)
        else
          @messages = @group.messages
        end
        render json: @messages
      else
        render json: {"error" => "No such group"}, status: :not_found
      end
    end

    # GET /messages/1
    # GET /messages/1.json
    def show
      @message = Message.find(params[:id])

      render json: @message
    end

    # POST /messages
    # POST /messages.json
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
    def destroy
      @message = Message.find(params[:id])
      if @message.author == @current_user
        @message.destroy
        head :no_content
      else
        render json: {"error"=>"message not found"}, status: :not_found
      end
    end

    private

      def message_create_params
        params.require(:message).permit(:message_body, :author)
      end

      def message_update_params
        params.require(:message).permit(:message_body)
      end
  end
end
