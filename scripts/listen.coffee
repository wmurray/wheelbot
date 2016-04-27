module.exports = (robot) ->

  robot.respond /here (.*) to there (.*)/i, (msg) ->
    origin = msg.match[1]
    destination = msg.match[2]
    originFormatted = splitAddress(origin)
    destinationFormatted = splitAddress(destination)
    key = process.env.GOOGLE_MAPS_TOKEN
    query = "?address=" + origin + "?key=" + key
    url = "https://maps.googleapis.com/maps/api/geocode/json" + query

    msg.http(url).get()((err, res, body) ->
      try
        data = JSON.parse(body)
        lat = data.results[0].geometry.location.lat
        lon = data.results[0].geometry.location.lon
        msg.send "For #{lat} #{lon}"
      catch error
        errMsg = res.statusCode
        msg.send "Error. Did you try to find the lat/lon of Neverland?"
        msg.send "#{errMsg}"
      )

  robot.hear /uber/i, (res) ->
    res.send "Looking for an Uber? To get the latest estimates, reply to me with \"current wait\"."

  robot.respond /current wait/i, (res) ->
    res.reply "Soon."

splitAddress = (add) ->
  add.split(" ").join("+");
