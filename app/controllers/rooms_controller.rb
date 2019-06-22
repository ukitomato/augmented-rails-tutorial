class RoomsController < ApplicationController
  before_action :logged_in_user, only: %i[index show create]

  def index
    @rooms = Room.includes(:users)
                 .where('users.id' => current_user.id).paginate(page: params[:page])
  end

  def show
    @rooms = Room.includes(:users)
                 .where('users.id' => current_user.id).paginate(page: params[:page], per_page: 5)

    if params[:id].present?
      @room = Room.find(params[:id])
      @messages = @room.microposts.paginate(page: params[:page])
      @message = current_user.microposts.build
    end
  end

  def create
    @room = current_user.rooms.build
    current_user.rooms << @room
    @room.direct_message(params['room']['user_id'])
    if @room.save
      flash[:success] = if @room.present?
                          'Room created!'
                        end
      redirect_to request.referer
    else
      render 'static_pages/home'
    end
  end

  def destroy
    Room.find(params[:id]).destroy
    flash[:success] = 'Room deleted'
    redirect_to messages_url
  end


  private

  def room_params
    params.permit(:user_id)
  end

end
