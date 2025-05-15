class Admin::AllowedStudentsController < ApplicationController
    layout 'admin'
    def new
        @allowed_student = AllowedStudent.new
        @allowed_students = AllowedStudent.all
      end
      

    def import_csv
      require 'csv'
      file = params[:file]
      unless file
        redirect_to new_admin_allowed_student_path, alert: "Lütfen bir CSV dosyası seçin." and return
      end
  
      CSV.foreach(file.path, headers: true) do |row|
        AllowedStudent.find_or_create_by(email: row["email"].downcase) do |student|
          student.name = row["name"]
          student.surname = row["surname"]
          student.student_number = row["student_number"]
        end
      end
  
      redirect_to new_admin_allowed_student_path, notice: "CSV başarıyla yüklendi."
    end
  end
  