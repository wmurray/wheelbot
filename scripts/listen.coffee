rp = require("request-promise")

module.exports = (robot) ->

  robot.respond /get me from (.*) to (.*)/i, (msg) ->
    origin = msg.match[1]
    destination = msg.match[2]
    originFormatted = formatAddress(origin)
    destinationFormatted = formatAddress(destination)

    gKey = process.env.GOOGLE_MAPS_TOKEN
    gQuery = "?origin=" + originFormatted + "&destination=" + destinationFormatted + "&key=" + gKey
    gUrl = "https://maps.googleapis.com/maps/api/directions/json" + gQuery

    googOpts =
      uri: gUrl
      headers:
        "User-Agent": "Request-Promise"
      json: true

    rp(googOpts)
      .then((gData) ->
        tripDetail = {}

        tripDetail.sLat = gData.routes[0].legs[0].start_location.lat
        tripDetail.sLng = gData.routes[0].legs[0].start_location.lng
        tripDetail.eLat = gData.routes[0].legs[0].end_location.lat
        tripDetail.eLng = gData.routes[0].legs[0].end_location.lng

        uOpts =
          uri: "https://api.uber.com/v1/estimates/price"
          headers:
            "Authorization": "Token " + process.env.UBER_TOKEN
          data: tripDetail
          json: true

        msg.send "#{tripDetail.sLat} and #{tripDetail.sLng} to #{tripDetail.eLat} and #{tripDetail.eLng}"

        rp(uOpts)
          .then((uData) ->
            msg.send "#{uData}"
        )
        .catch((uErr) ->
          errMsg = uErr.statusCode
          msg.send "Error, code: #{errMsg}. Uber API doesn't like your shenanigans."
        )
      )
      .catch((err) ->
        errMsg = err.statusCode
        msg.send "Error, code: #{errMsg}. Did you try to find directions to/in Neverland?"
        msg.send "Check the address and try again."
      )

formatAddress = (add) ->
  add.split(" ").join("+");
