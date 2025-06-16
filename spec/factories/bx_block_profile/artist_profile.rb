FactoryBot.define do
    factory :artist_profile, class: 'BxBlockProfile::ArtistProfile' do
      association :account, factory: :account
    end
end