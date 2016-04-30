rp = require("request-promise")

module.exports = (robot) ->

  robot.respond /get me from (.*) to (.*)/i, (msg) ->
    origin = msg.match[1]
    destination = msg.match[2]
    originFormatted = formatAddress(origin)
    destinationFormatted = formatAddress(destination)

    uUrl = "https://sandbox-api.uber.com/v1/products"

    gKey = process.env.GOOGLE_MAPS_TOKEN
    gQuery = "?origin=" + originFormatted + "&destination=" + destinationFormatted + "&key=" + gKey
    gUrl = "https://maps.googleapis.com/maps/api/directions/json" + gQuery

    googOpts =
      uri: gUrl
      headers:
        "User-Agent": "Request-Promise"
      json: true

    params =
      server_token: process.env.UBER_SERVER_TOKEN
      longitude: -71.1781431
      latitude: 42.3493675
      json: true


    rp(options, params)
      .then((uData) ->
        msg.send "#{uData}"
    )
    .catch((uErr) ->
      errMsg = uErr.message
      errCode = uErr.statusCode
      msg.send "#{errMsg}. Code: #{errCode}."
      msg.send "Uber doesn't like your shenanigans."
    )

formatAddress = (add) ->
  add.split(" ").join("+");
