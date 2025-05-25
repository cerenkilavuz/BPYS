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
      
        unless File.extname(file.original_filename).downcase == ".csv"
          redirect_to new_admin_allowed_student_path, alert: "Sadece CSV uzantılı dosyalar kabul edilir." and return
        end
      
        errors = []
        line_number = 1
      
        begin
          CSV.foreach(file.path, headers: true) do |row|
            line_number += 1
      
            name            = row["name"]&.strip
            surname         = row["surname"]&.strip
            student_number  = row["student_number"]&.strip
            email           = row["email"]&.strip
      
            if name.blank? || surname.blank? || student_number.blank? || email.blank?
              errors << "Satır #{line_number}: Tüm alanlar doldurulmalıdır."
              next
            end
      
            unless email =~ URI::MailTo::EMAIL_REGEXP
              errors << "Satır #{line_number}: Geçersiz e-posta formatı: #{email}"
              next
            end
      
            student = AllowedStudent.find_or_initialize_by(email: email, student_number: student_number)
            student.name = name
            student.surname = surname
      
            unless student.save
              errors << "Satır #{line_number}: Kayıt yapılamadı."
            end
          end
      
          if errors.any?
            flash[:alert] = errors.join("<br>").html_safe
          else
            flash[:notice] = "CSV başarıyla yüklendi."
          end
      
        rescue CSV::MalformedCSVError => e
          flash[:alert] = "CSV dosyası hatalı veya bozuk."
        end
      
        redirect_to new_admin_allowed_student_path
        
      end

      def destroy
        student = AllowedStudent.find(params[:id])
        student.destroy
        redirect_to new_admin_allowed_student_path, notice: "Öğrenci silindi."
      end
      
  end
  