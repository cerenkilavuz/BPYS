class Student::GroupMembersController < ApplicationController
  before_action :authenticate_user!

  def create
    @group = Group.find(params[:group_id])
    student = User.find_by(email: params[:email])

    if student.nil?
      redirect_to student_groups_path, alert: "Böyle bir öğrenci bulunamadı."
    elsif student.group.present?
      redirect_to student_groups_path, alert: "Bu öğrenci zaten bir gruba üye."
    else
      @group.group_members.create(student: student)
      redirect_to student_groups_path, notice: "#{student.email} gruba eklendi."
    end
  end
end
