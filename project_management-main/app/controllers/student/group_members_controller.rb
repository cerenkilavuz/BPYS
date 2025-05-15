class Student::GroupMembersController < ApplicationController
  before_action :authenticate_user!

  def create
    @group = Group.find(params[:group_id])
    student = User.find(params[:student_id])

    if student.group.present?
      redirect_to student_groups_path, alert: "Bu öğrenci zaten bir gruba üye."
    else
      GroupMembership.create(group: @group, student: student)
      redirect_to student_groups_path, notice: "#{student.email} gruba eklendi."
    end
  end
end
