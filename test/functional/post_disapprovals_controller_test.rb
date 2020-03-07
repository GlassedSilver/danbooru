require 'test_helper'

class PostDisapprovalsControllerTest < ActionDispatch::IntegrationTest
  context "The post disapprovals controller" do
    setup do
      @admin = create(:admin_user)
      as_user do
        @post = create(:post, :is_pending => true)
      end

      CurrentUser.user = @admin
    end

    context "create action" do
      should "render" do
        assert_difference("PostDisapproval.count", 1) do
          post_auth post_disapprovals_path, @admin, params: { post_disapproval: { post_id: @post.id, reason: "breaks_rules" }, format: "js" }
        end
        assert_response :success
      end

      context "for json" do
        should "render" do
          assert_difference("PostDisapproval.count", 1) do
            post_auth post_disapprovals_path, @admin, params: { post_disapproval: { post_id: @post.id, reason: "breaks_rules" }, format: "json" }
          end
          assert_response :success
        end
      end
    end

    context "index action" do
      should "render" do
        disapproval = FactoryBot.create(:post_disapproval, post: @post)
        get_auth post_disapprovals_path, @admin

        assert_response :success
      end
    end
  end
end
