class PostFlagsController < ApplicationController
  before_action :member_only, :except => [:index, :show]
  respond_to :html, :xml, :json, :js

  def new
    @post_flag = PostFlag.new(post_flag_params)
    respond_with(@post_flag)
  end

  def index
    @post_flags = PostFlag.paginated_search(params)

    if request.format.html?
      @post_flags = @post_flags.includes(:creator, post: [:flags, :uploader, :approver])
    else
      @post_flags = @post_flags.includes(:post)
    end

    respond_with(@post_flags)
  end

  def create
    @post_flag = PostFlag.create(post_flag_params.merge(creator: CurrentUser.user))
    flash[:notice] = @post_flag.errors.none? ? "Post flagged" : @post_flag.errors.full_messages.join("; ")
    respond_with(@post_flag)
  end

  def show
    @post_flag = PostFlag.find(params[:id])
    respond_with(@post_flag) do |fmt|
      fmt.html { redirect_to post_flags_path(search: { id: @post_flag.id }) }
    end
  end

  private

  def post_flag_params
    params.fetch(:post_flag, {}).permit(%i[post_id reason])
  end
end
