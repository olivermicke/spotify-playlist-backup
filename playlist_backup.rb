# frozen_string_literal: true

require 'json'
require 'rspotify'

CONFIG = JSON.parse(File.read('config.json'))
# Limitation of Spotify API
PAGINATION_MAX = 100

RSpotify.authenticate(CONFIG['CLIENT_ID'], CONFIG['CLIENT_SECRET'])

def track_ids_for_offset(offset)
  RSpotify::Playlist
    .find(CONFIG['USERNAME'], CONFIG['PLAYLIST_ID'])
    .tracks(offset: offset)
    .map(&:id)
end

track_ids = []

current_offset = 0
track_ids_for_current_offset = track_ids_for_offset(current_offset)

until track_ids_for_current_offset.empty?
  track_ids_for_current_offset.each { |id| track_ids.push(id) }

  current_offset += PAGINATION_MAX
  track_ids_for_current_offset = track_ids_for_offset(current_offset)
end

File.open(CONFIG['OUTPUT_FILE'], 'w') { |file| file.write(JSON[track_ids]) }

puts 'Successfully backed up your song IDs.'
