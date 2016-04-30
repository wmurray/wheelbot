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

    uOpts =
      "options":
        "uri": "https://api.uber.com/v1/estimates/price"
        "headers":
          "Authorization": "Token " + process.env.UBER_SERVER_TOKEN

    rp(googOpts)
      .then((gData) ->
        uOpts.start_latitude = gData.routes[0].legs[0].start_location.lat
        uOpts.start_longitude = gData.routes[0].legs[0].start_location.lng
        uOpts.end_latitude = gData.routes[0].legs[0].end_location.lat
        uOpts.end_longitude = gData.routes[0].legs[0].end_location.lng
      )
      .then((uOpts) ->
        rp(uOpts)
          .then((uData) ->
            msg.send "#{uData}"
        )
        .catch((uErr) ->
          errMsg = uErr.message
          errCode = uErr.statusCode
          msg.send "Error, code: #{errCode}. Message: #{errMsg}"
          msg.send "Uber API doesn't like your shenanigans."
        )
      )
      .catch((err) ->
        errMsg = err.statusCode
        msg.send "Error, code: #{errMsg}. Did you try to find directions to/in Neverland?"
        msg.send "Check the address and try again."
      )

formatAddress = (add) ->
  add.split(" ").join("+");
