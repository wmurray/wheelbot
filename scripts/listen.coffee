module.exports = (robot) ->

  robot.respond /here (.*)/i, (msg) ->
    origin = splitAddress(msg.match[1])
    key = process.env.GOOGLE_MAPS_TOKEN
    query = "?address=" + origin + "?key=" + key
    url = "https://maps.googleapis.com/maps/api/geocode/json" + query

    msg.http(url).get()((err, res, body) ->
      try
        data = JSON.parse(body)
        msg.send "#{data.results[0].geometry.location.lat}"
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
