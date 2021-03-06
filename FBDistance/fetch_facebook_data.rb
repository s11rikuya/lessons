module GetFBData
  def getData()
    @graph = Koala::Facebook::API.new(ACSESS_TORKEN)
    @graph_result = @graph.get_connection('me', 'posts', { fields: %w(place created_time) } )
    @results = @graph_result.to_a
    until (next_results = @graph_result.next_page).nil?
      @results += next_results.to_a
      @graph_result = next_results
    end
    @graph = Koala::Facebook::API.new(ACSESS_TORKEN, APP_SCRET)
    data_indexs = @results
    return data_indexs
  end

  def filter(data_indexs,from_time,to_time)
    range_indexs = []
    data_indexs.each do |index|
      next unless index['place'] && index['created_time']
      next unless from_time <= Time.parse(index['created_time']) && Time.parse(index['created_time']) <= to_time
      container = {}
      container['name'] = index['place']['name']
      container['lat'] = index['place']['location']['latitude']
      container['lng'] = index['place']['location']['longitude']
      range_indexs.push(container)
    end
    return range_indexs
  end
end
