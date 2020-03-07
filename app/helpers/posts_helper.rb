module PostsHelper
  def post_previews_html(posts, **options)
    posts.map do |post|
      PostPresenter.preview(post, **options)
    end.join("").html_safe
  end

  def post_search_counts_enabled?
    Danbooru.config.enable_post_search_counts && Danbooru.config.reportbooru_server.present? && Danbooru.config.reportbooru_key.present?
  end

  def discover_mode?
    params[:tags] =~ /order:rank/ || params[:action] =~ /searches|viewed/
  end

  def missed_post_search_count_js
    return unless post_search_counts_enabled?
    return unless params[:ms] == "1" && @post_set.post_count == 0 && @post_set.is_single_tag?

    sig = generate_reportbooru_signature(params[:tags])
    render "posts/partials/index/missed_search_count", sig: sig
  end

  def post_search_count_js
    return unless post_search_counts_enabled?
    return unless params[:action] == "index" && params[:page].nil? && params[:tags].present?

    tags = PostQueryBuilder.scan_query(params[:tags]).sort.join(" ")
    sig = generate_reportbooru_signature("ps-#{tags}")
    render "posts/partials/index/search_count", sig: sig
  end

  def post_view_count_js
    return unless post_search_counts_enabled?

    msg = generate_reportbooru_signature(params[:id])
    render "posts/partials/show/view_count", msg: msg
  end

  def generate_reportbooru_signature(value)
    verifier = ActiveSupport::MessageVerifier.new(Danbooru.config.reportbooru_key, serializer: JSON, digest: "SHA256")
    verifier.generate("#{value},#{session[:session_id]}")
  end

  def post_source_tag(post)
    # Only allow http:// and https:// links. Disallow javascript: links.
    if post.source =~ %r!\Ahttps?://!i
      external_link_to(post.normalized_source, strip: :subdomain) + "&nbsp;".html_safe + link_to("»", post.source, rel: "external noreferrer nofollow")
    else
      post.source
    end
  end

  def post_favlist(post)
    post.favorited_users.reverse_each.map {|user| link_to_user(user)}.join(", ").html_safe
  end

  def is_pool_selected?(pool)
    return false if params.key?(:q)
    return false if params.key?(:favgroup_id)
    return false if !params.key?(:pool_id)
    return params[:pool_id].to_i == pool.id
  end

  def show_tag_change_notice?
    PostQueryBuilder.scan_query(params[:tags]).size == 1 && TagChangeNoticeService.get_forum_topic_id(params[:tags])
  end

  private

  def nav_params_for(page)
    query_params = params.except(:controller, :action, :id).merge(page: page).permit!
    { params: query_params }
  end
end
