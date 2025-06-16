module BxBlockProfile
	class UserSkill < ApplicationRecord
		self.table_name  = :user_skills
    belongs_to :account, class_name: "AccountBlock::Account"
  
		enum category: {
      acting_performance: 'Acting & Performance',
      music_singing: 'Music & Singing',
      dance_movement: 'Dance & Movement',
      magic_illusions: 'Magic & Illusions',
      hosting_public_speaking: 'Hosting & Public Speaking',
      film_media_production: 'Film & Media Production',
      modeling_fashion: 'Modeling & Fashion',
      writing_literature: 'Writing & Literature',
      circus_extreme_performances: 'Circus & Extreme Performances',
      other_entertainment_fields: 'Other Entertainment Fields'
    }, _suffix: true
    
  end
end