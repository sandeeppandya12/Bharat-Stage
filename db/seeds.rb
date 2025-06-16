# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

admin_user = AdminUser.find_or_initialize_by(email: "admin@test.com")
unless admin_user.persisted?
    admin_user.password = "admin@123"
    admin_user.save
end

BxBlockCustomUserSubs::Subscription.destroy_all unless BxBlockCustomUserSubs::Subscription.count == 3
suscription = BxBlockCustomUserSubs::Subscription.find_or_initialize_by(name: "Free")
unless suscription.persisted?
    suscription.price = 0
    suscription.save
end
suscription1 = BxBlockCustomUserSubs::Subscription.find_or_initialize_by(name: "Monthly")
unless suscription1.persisted?
    suscription1.price = 0
    suscription1.save
end
suscription2 = BxBlockCustomUserSubs::Subscription.find_or_initialize_by(name: "Yearly")
unless suscription2.persisted?
    suscription2.price = 0
    suscription2.save
end



# languages = [
#   'Afrikaans', 'Albanian', 'Amharic', 'Arabic', 'Armenian', 'Assamese', 'Azerbaijani',
#   'Basque', 'Belarusian', 'Bengali', 'Bulgarian', 'Burmese', 'Catalan', 'Cebuano',
#   'Croatian', 'Czech', 'Danish', 'Dutch', 'English', 'Esperanto', 'Estonian',
#   'Filipino/Tagalog', 'Finnish', 'French', 'Galician', 'Georgian', 'German', 'Greek',
#   'Gujarati', 'Hebrew', 'Hindi', 'Hungarian', 'Icelandic', 'Irish (Gaelic)', 'Italian',
#   'Japanese', 'Javanese', 'Kazakh', 'Khmer', 'Kinyarwanda', 'Korean', 'Kyrgyz', 'Lao',
#   'Latvian', 'Lithuanian', 'Macedonian', 'Malay/Indonesian', 'Malayalam', 'Maltese',
#   'Mandarin Chinese', 'Marathi', 'Mongolian', 'Nepali', 'Norwegian', 'Pashto',
#   'Persian (Farsi)', 'Polish', 'Portuguese', 'Punjabi', 'Romanian', 'Russian',
#   'Scots Gaelic', 'Serbian', 'Sinhala', 'Slovak', 'Slovenian', 'Somali', 'Spanish',
#   'Swahili', 'Swedish', 'Tajik', 'Tamil', 'Telugu', 'Thai', 'Tibetan', 'Turkish',
#   'Turkmen', 'Ukrainian', 'Urdu', 'Uyghur', 'Uzbek', 'Vietnamese', 'Welsh', 'Yiddish',
#   'Yoruba', 'Zulu'
# ]

# languages.each do |language|
#   UserLanguage.find_or_create_by(name: language)
# end


