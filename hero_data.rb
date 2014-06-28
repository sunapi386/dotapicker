require "JSON"


class Match
	attr_accessor :victor, :picks, :data
	@picking_side = [0,1,0,1,0,1,1,0,0,1,0,1,1,0,1,0,1,0,1,0]
	
	def initialize(match_data)
		json = JSON.parse(match_data,{})
		@victor = json['result']['radiant_win'] ? 0 : 1
		@picks = json['result']['picks_bans'].map{|x| x['hero_id']}
		@data = HeroVS.new(picks[0],nil,0,nil, victor)
		(1..19).map{|x| (0..(x-1)).map{|y| 
			a = HeroVS.new(picks[x], picks[y], x, y, victor)
			@data.vs_merge(a)
		}}
		@data
	end
end

class HeroCalc
	attr_accessor :match_data
	def initialize(matches)
		init = Match.new(File.read(matches[0]))
		if matches.length == 1
			@match_data = init
		else 
			@match_data = matches[1..-1].inject(init){|d, f| d.vs_merge(Match.new(File.read(f)))}
		end
		@match_data = @match_data.data
	end
end

class HeroVS
	attr_accessor :hero_data, :picking_side
	@@picking_side = [0,1,0,1,0,1,1,0,0,1,0,1,1,0,1,0,1,0,1,0]
	
	def initialize(hero_id1, hero_id2, pick1, pick2, victor)
		won = @@picking_side[pick1] == victor
		@hero_data = Hash.new
		@hero_data[hero_id1] = Hash.new
		@hero_data[hero_id1][[hero_id2,pick1,pick2]] = won ? [1,0] : [0,1]
	end
	def vs_merge(other_hero_vs)
		@hero_data = @hero_data.merge(other_hero_vs.hero_data) {|k, cur, new|
			cur.merge(new) {|k, cur, new|
				a,b = cur
				c,d = new
				[a+c, b+d]
			}
		}
	end
	def query(picked)
		if picked == []
			(0..107).map{|x| hero_data[x][nil,0,nil] }.sort.reverse
		else
			place = picked.length
			picked.zip(0..place-1).map{|y,p| (0..107).map{|x| hero_data[x][y,place,p]
			}
		end
	end
end