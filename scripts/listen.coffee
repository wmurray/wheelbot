Uber = require('uber-api')({server_token:process.env.UBER_SERVER_TOKEN,version:'v1'})

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

    tripDetail =
      callback: (err, res, msg) ->
        if err
          msg.send "#{err}"
        else
          msg.send "#{res}"

    msg.http(gUrl).get()((err, res, body) ->
      try
        data = JSON.parse(body)
        tripDetail.sLat = data.routes[0].legs[0].start_location.lat
        tripDetail.sLon = data.routes[0].legs[0].start_location.lng
        tripDetail.eLat = data.routes[0].legs[0].end_location.lat
        tripDetail.eLon = data.routes[0].legs[0].end_location.lng
      catch error
        errMsg = res.statusCode
        msg.send "Error, code: #{errMsg}. Did you try to find directions to/in Neverland?"
        msg.send "Check the address and try again."
      )

    Uber.getPriceEstimate(tripDetail.sLat, tripDetail.sLon, tripDetail.eLat, tripDetail.eLon, tripDetail.callback(error, response, msg))

formatAddress = (add) ->
  add.split(" ").join("+");
