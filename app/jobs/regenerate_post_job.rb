# A job that regenerates a post's images and IQDB when a moderator requests it.
class RegeneratePostJob < ApplicationJob
  queue_as :default
  queue_with_priority 20

  def perform(post:, category:, user:)
    post.regenerate!(category, user)
  end
end
