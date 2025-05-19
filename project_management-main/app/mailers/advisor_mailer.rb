# app/mailers/advisor_mailer.rb

class AdvisorMailer < ApplicationMailer
    default from: ENV['SMTP_USERNAME']
    def send_temporary_password(advisor, password)
      @advisor = advisor
      @password = password
      mail(to: advisor.email, subject: "Geçici Şifreniz - Bitirme Proje Sistemi")
    end
end
  