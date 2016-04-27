module.exports = (robot) ->

  robot.respond /get me from (.*) to (.*)/i, (msg) ->
    origin = msg.match[1]
    destination = msg.match[2]
    originFormatted = formatAddress(origin)
    destinationFormatted = formatAddress(destination)
    gKey = process.env.GOOGLE_MAPS_TOKEN
    gQuery = "?origin=" + originFormatted + "&destination=" + destinationFormatted + "&key=" + gKey
    gUrl = "https://maps.googleapis.com/maps/api/directions/json" + gQuery
    uKey = process.env.UBER_SERVER_TOKEN
    uUrl = 'https://api.uber.com/v1/estimates/price'

    tripDetail = {}

    msg.http(gUrl).get()((err, res, body) ->
      try
        data = JSON.parse(body)
        tripDetail.start_latitude = data.routes[0].legs[0].start_location.lat
        tripDetail.start_longitude = data.routes[0].legs[0].start_location.lng
        tripDetail.end_latitude = data.routes[0].legs[0].end_location.lat
        tripDetail.end_longitude = data.routes[0].legs[0].end_location.lng
      catch error
        errMsg = res.statusCode
        msg.send "Error, code: #{errMsg}. Did you try to find directions to/in Neverland?"
        msg.send "Check the address and try again."
      )

    checkUber(msg uUrl uKey)

  robot.respond /uber/i, (res) ->
    res.reply "Soon."

formatAddress = (add) ->
  add.split(" ").join("+");

checkUber =  (msg, uUrl, uKey) ->
  url = uUrl
  headers =
    Authorization: "Token " + uKey
  params = tripDetail
  $.get(url, headers, params, (response)->
    msg.send "#{response}"
  , "json")
