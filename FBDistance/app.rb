require 'time'
require 'json'
require 'open-uri'
require 'rubygems'
require 'bundler/setup'
require 'koala'
require_relative 'fetch_facebook_data.rb'
require_relative 'point_calculation.rb'

ACSESS_TORKEN = 'XXXXXXXXXXXXXX'.freeze
APP_SCRET = 'XXXXXXXXXXXX'.freeze

class History
  include GetFBData
  include PointCalculation
end

rikuya = History.new()
from_time = Time.parse('2017/01/01 00:00:00')
to_time = Time.parse('2018/01/01 00:00:00')
data_indexs = rikuya.getData()
p range_indexs = rikuya.filter(data_indexs,from_time,to_time)
count_point = range_indexs.size
sum_distance = rikuya.culculation(range_indexs)
puts "チェックイン数:#{count_point}"
puts "あなたの今年の総移動距離は#{sum_distance}kmです。"
