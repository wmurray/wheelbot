module.exports = (robot) ->

  robot.respond /get me from (.*) to (.*)/i, (msg) ->
    origin = msg.match[1]
    destination = msg.match[2]
    originFormatted = formatAddress(origin)
    destinationFormatted = formatAddress(destination)
    gKey = process.env.GOOGLE_MAPS_TOKEN
    gQuery = "?origin=" + originFormatted + "&destination=" + destinationFormatted + "&key=" + gKey
    gUrl = "https://maps.googleapis.com/maps/api/directions/json" + gQuery
    uUrl = 'https://api.uber.com/v1/estimates/price'

    tripDetail = {}

    msg.http(gUrl).get().then((err, res, body) ->
      try
        data = JSON.parse(body)
        tripDetail.sLat = data.routes[0].legs[0].start_location.lat
        tripDetail.sLng = data.routes[0].legs[0].start_location.lng
        tripDetail.eLat = data.routes[0].legs[0].end_location.lat
        tripDetail.eLng = data.routes[0].legs[0].end_location.lng

        msg.send "#{tripDetail.sLat} and #{tripDetail.sLng} to #{tripDetail.eLat} and #{tripDetail.eLng}"

      catch error
        errMsg = res.statusCode
        msg.send "Error, code: #{errMsg}. Did you try to find directions to/in Neverland?"
        msg.send "Check the address and try again."
      )

formatAddress = (add) ->
  add.split(" ").join("+");
