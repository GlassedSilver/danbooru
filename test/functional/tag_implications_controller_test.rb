require 'test_helper'

class TagImplicationsControllerTest < ActionDispatch::IntegrationTest
  context "The tag implications controller" do
    setup do
      @user = create(:admin_user)
      @tag_implication = create(:tag_implication, antecedent_name: "aaa", consequent_name: "bbb")
    end

    context "index action" do
      should "list all tag implications" do
        get tag_implications_path
        assert_response :success
      end

      should "list all tag_implications (with search)" do
        get tag_implications_path, params: {:search => {:antecedent_name => "aaa"}}
        assert_response :success
      end
    end

    context "destroy action" do
      should "mark the implication as deleted" do
        assert_difference("TagImplication.count", 0) do
          delete_auth tag_implication_path(@tag_implication), @user
          assert_equal("deleted", @tag_implication.reload.status)
        end
      end
    end
  end
end
