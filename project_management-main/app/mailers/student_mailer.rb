# app/mailers/student_mailer.rb
class StudentMailer < ApplicationMailer
    def group_reminder_email(student)
      @student = student
      mail(
        to: @student.email,
        subject: "Grup oluşturma hatırlatması"
      )
    end
  end
  