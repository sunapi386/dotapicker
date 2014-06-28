require 'open-uri'
require 'json'

API_KEY = 'BAD3D130F4D06DB91EB99C1009E4A8BD'

# getHistory queries your params to GetMatchHistory and returns a json object
# player_name=<name> # Search matches with a player name, exact match only
# hero_id=<id> # Search for matches with a specific hero being played, hero id's are in dota/scripts/npc/npc_heroes.txt in your Dota install directory
# skill=<skill>  # 0 for any, 1 for normal, 2 for high, 3 for very high skill
# date_min=<date> # date in UTC seconds since Jan 1, 1970 (unix time format)
# date_max=<date> # date in UTC seconds since Jan 1, 1970 (unix time format)
# account_id=<id> # Steam account id (this is not SteamID, its only the account number portion)
# league_id=<id> # matches for a particular league
# start_at_match_id=<id> # Start the search at the indicated match id, descending
# matches_requested=<n> # Defaults is 25 matches, this can limit to less
# Example: getHistory('skill=3')

# getDetails is like getHistory but queries to GetMatchDetails
def getDetails(match_id)
    url = "https://api.steampowered.com/IDOTA2Match_570/GetMatchDetails/V001/?match_id=#{match_id}&key=#{API_KEY}"
    puts "Fetching #{url}"
    JSON.load(open(url))
end

class History
    def initialize(*params)
        url = "https://api.steampowered.com/IDOTA2Match_570/GetMatchHistory/V001/?#{params.join('').to_s}&key=#{API_KEY}"
        puts "Fetching #{url}"
        @history = JSON.load(open(url))
    end

    def get_matchids # return a list of match ids
        @history['result']['matches'].collect { |match| match['match_id'] }
    end

    def get_matchids_ranked
        @history['result']['matches'].collect { |match| match['match_id'] if match['lobby_type']  == 7 }
    end

    def get_lobbytypes
        @history['result']['matches'].collect { |match| match['lobby_type'] }
    end

    def get_players
        @history['result']['matches'].collect { |match| match['players'] }
    end

    def get_position(position)
        @history['result']['matches'][position]
    end
end

class Match
    def initialize(match_id)
        @detail = getDetails(match_id)
    end

    def is_captainsmode?
        !@detail['result']['picks_bans'].nil?
    end

    def get_duration
        @detail['result']['duration']
    end

    def get_matchid
        @detail['result']['match_id']
    end
end

# getMatchIds takes a json from getHistory and returns list of match ids that has 10 players
def getMatchIds(history_json)
    history_json['result']['matches'].collect { |match| match if match['players'].count == 10}.compact
    .collect { |match| match['match_id'] }
end

# selectDuration takes a collection of match details (getDetails) and removes matches that don't meet required duration
def selectDuration(matchDetails, greaterThan)
    matchDetails.collect { |detail| detail if detail['result']['duration'] > greaterThan }.compact
end

# selectCaptainsMode like selectDuration, but selects only captains mode games
def selectCaptainsMode(matchDetails)
    matchDetails.collect{ |detail| detail if !detail['result']['picks_bans'].nil? }.compact
end


#history = History.new ('skill=3')
#match_ids = getMatchIds(history)
#matchDetails = match_ids.collect { |id| getDetails(id) }
#selectCaptainsMode(matchDetails)

history = History.new ('skill=3')
rankedids = history.get_matchids_ranked.compact
puts rankedids
rankedMatches = rankedids.collect { |id| Match.new (id) }
rankedMatches.each { |match| puts "#{match.get_matchid} -- #{match.is_captainsmode?}" }
