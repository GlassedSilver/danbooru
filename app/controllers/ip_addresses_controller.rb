class IpAddressesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :moderator_only

  def index
    @ip_addresses = IpAddress.visible(CurrentUser.user).paginated_search(params)

    if search_params[:group_by] == "ip_addr"
      @ip_addresses = @ip_addresses.group_by_ip_addr(search_params[:ipv4_masklen], search_params[:ipv6_masklen])
    elsif search_params[:group_by] == "user"
      @ip_addresses = @ip_addresses.group_by_user.includes(:user)
    else
      @ip_addresses = @ip_addresses.includes(:user, :model)
    end

    respond_with(@ip_addresses)
  end
end
