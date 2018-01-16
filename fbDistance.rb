require 'koala'
require 'time'
require 'json'
require 'open-uri'

ACSESS_TORKEN = 'XXXX'
APP_SCRET = 'XXXXXXX'.freeze
FROM_TIME = Time.parse('2017/01/01 00:00:00')
TO_TIME = Time.parse('2018/01/01 00:00:00')
DISTANCE_API = 'http://vldb.gsi.go.jp/sokuchi/surveycalc/surveycalc/bl2st_calc.pl?'.freeze

def distance(lat1, lng1, lat2, lng2)
  req_params = {
    outputType: 'json',    # 出力タイプ
    ellipsoid:  'bessel',  # 楕円体
    latitude1:  lat1,      # 出発点緯度
    longitude1: lng1,      # 出発点経度
    latitude2:  lat2,      # 到着点緯度
    longitude2: lng2       # 到着点経度
  }

  req_param = req_params.map { |k, v| "#{k}=#{v}" }.join('&')
  result = JSON.parse(open(DISTANCE_API + req_param).read)
  result['OutputData']['geoLength']
end

@graph = Koala::Facebook::API.new(ACSESS_TORKEN)
@graph_result = @graph.get_connection('me', 'posts', { fields: %w(place created_time) } )
@results = @graph_result.to_a

until (next_results = @graph_result.next_page).nil?
  @results += next_results.to_a
  @graph_result = next_results
end

indexs = []
@results.each do |result|
  next unless result['place'] && result['created_time']
  next unless FROM_TIME <= Time.parse(result['created_time']) && Time.parse(result['created_time']) <= TO_TIME
  index = {}
  index['name'] = result['place']['name']
  index['lat'] = result['place']['location']['latitude']
  index['lng'] = result['place']['location']['longitude']
  indexs.push(index)
end

p sequence = indexs.reverse

distanes = []
indexs.each_cons(2) do |a, b|
  c = distance(a['lat'], a['lng'], b['lat'], b['lng'])
  c = c.to_i
  distanes.push(c)
end
p distanes
sum_distance = distanes.inject(:+) / 1000
count_point = indexs.size
puts "チェックイン数:#{count_point}"
puts "あなたの今年の総移動距離は#{sum_distance}kmです。"

# indexs 期間内のpostsのチェックインの座標の配列(新しい順)
# countPoint チェックインの数
# sequence 座標の配列(古い順)
# distanes　2点間の座標の距離
# sumDistance  その合計

@graph = Koala::Facebook::API.new(ACSESS_TORKEN, APP_SCRET)
