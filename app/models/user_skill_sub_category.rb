class UserSkillSubCategory < ApplicationRecord
  belongs_to :user_skill

  enum sub_category: {
  theater_acting: "Theater Acting",
  film_tv_acting: "Film & TV Acting",
  voice_acting: "Voice Acting",
  standup_comedy: "Stand-up Comedy",
  classical_singing: "Classical Singing",
  rock_singing: "Rock Singing",
  jazz_singing: "Jazz Singing",
  hip_hop_singing: "Hip-Hop Singing",
  instrument_playing: "Instrument Playing",
  ballet: "Ballet",
  hip_hop_dance: "Hip-Hop Dance",
  contemporary_dance: "Contemporary Dance",
  breakdancing: "Breakdancing",
  close_up_magic: "Close-up Magic",
  stage_magic: "Stage Magic",
  mentalism: "Mentalism",
  tv_hosting: "TV Hosting",
  event_hosting: "Event Hosting",
  motivational_speaking: "Motivational Speaking",
  directing: "Directing",
  cinematography: "Cinematography",
  video_editing: "Video Editing",
  runway_modeling: "Runway Modeling",
  commercial_modeling: "Commercial Modeling",
  fashion_photography: "Fashion Photography",
  screenwriting: "Screenwriting",
  poetry: "Poetry",
  novel_writing: "Novel Writing",
  acrobatics: "Acrobatics",
  fire_dancing: "Fire Dancing",
  aerial_silks: "Aerial Silks",
  puppetry: "Puppetry",
  mime_acting: "Mime Acting"
}, _suffix: true

end
