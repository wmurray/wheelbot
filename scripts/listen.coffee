module.exports = (robot) ->

  robot.respond /directions from (.*) to (.*)/i, (msg) ->
    origin = msg.match[1]
    destination = msg.match[2]
    originFormatted = formatAddress(origin)
    destinationFormatted = formatAddress(destination)
    key = process.env.GOOGLE_MAPS_TOKEN
    query = "?origin=" + originFormatted + "?destination=" + destinationFormatted + "?key=" + key
    url = "https://maps.googleapis.com/maps/api/directions/json" + query

    endPoints =
      startLat: 0
      startLon: 0
      endLat: 0
      endLon: 0

    msg.http(url).get()((err, res, body) ->
      try
        data = JSON.parse(body)
        endPoints.startLat = data.routes[0].legs.start_location.lat
        endPoints.startLon = data.routes[0].legs._startlocation.lon
        endPoints.endLat = data.routes[0].legs.end_location.lat
        endPoints.endLon = data.routes[0].legs.end_location.lon
        msg.send "For #{endPoints.startLat} #{startLon} to #{endLat} #{endLon}"
      catch error
        errMsg = res.statusCode
        msg.send "Error, code: #{errMsg}. Did you try to find directions to/in Neverland?"
      )

  robot.respond /uber/i, (res) ->
    res.reply "Soon."

formatAddress = (add) ->
  add.split(" ").join("+");
