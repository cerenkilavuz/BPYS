require "test_helper"

class GroupTest < ActiveSupport::TestCase
  test "bir grup silindiğinde ilişkili group_membership kayıtları da silinir" do
    group = Group.create!(name: "Test Grubu")
    user = User.create!(email: "ogrenci@example.com", password: "123123", role: :student)
    group.group_memberships.create!(user: user)

    assert_difference("GroupMembership.count", -1) do
      group.destroy
    end
  end
end
