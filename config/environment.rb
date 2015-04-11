# Load the rails application
require File.expand_path('../application', __FILE__)
Time::DATE_FORMATS[:ru_datetime] = "%d.%m.%Y в %k:%M:%S"

# Initialize the rails application
VisotaParaclubRu::Application.initialize!

ActionMailer::Base.delivery_method = :sendmail

# ActionMailer::Base.smtp_settings = {
  # :address              => "smtp.yandex.ru",
  # :port                 => 587,
  # :domain               => 'visota-paraclub.ru',
  # :user_name            => 'noreply@visota-paraclub.ru',
  # :password             => 'koz13onin',
  # :authentication       => 'plain',
  # :enable_starttls_auto => true  }