module.exports = (robot) ->

  robot.respond /here (.*)/i, (msg) ->
    origin = splitAddress(msg.match[1])
    key = process.env.GOOGLE_MAPS_TOKEN
    url = "https://maps.googleapis.com/maps/api/geocode/json"
    query =
      origin: origin
      key: key

    msg.http(url + "?address=" + query).get()(err, res, body) ->
      try
        data = JSON.parse(body)
        lat = data.geometry.location.lat
        lon = data.geometry.location.lon
        msg.send "Latitude: #{lat}, Longitude: #{lon}"
      catch error
        msg.send "Error. Did you try to find the lat/lon of Neverland?"
        msg.send "#{origin}"

  robot.hear /uber/i, (res) ->
    res.send "Looking for an Uber? To get the latest estimates, reply to me with \"current wait\"."

  robot.respond /current wait/i, (res) ->
    res.reply "Soon."

splitAddress = (add) ->
  add.split(" ").join("+");
