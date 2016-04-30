rp = require("request-promise")

module.exports = (robot) ->

  robot.respond /get me from (.*) to (.*)/i, (msg) ->
    origin = msg.match[1]
    destination = msg.match[2]
    originFormatted = formatAddress(origin)
    destinationFormatted = formatAddress(destination)

    uUrl = "https://api.uber.com/v1/estimates/price"

    gKey = process.env.GOOGLE_MAPS_TOKEN
    gQuery = "?origin=" + originFormatted + "&destination=" + destinationFormatted + "&key=" + gKey
    gUrl = "https://maps.googleapis.com/maps/api/directions/json" + gQuery

    googOpts =
      uri: gUrl
      headers:
        "User-Agent": "Request-Promise"
      json: true

    options =
      uri: "https://api.uber.com/v1/estimates/price"
      headers:
        "Authorization": "Token " + process.env.UBER_SERVER_TOKEN
      data: {}

    rp(googOpts)
      .then((gData) ->
        options.data.start_latitude = gData.routes[0].legs[0].start_location.lat
        options.data.start_longitude = gData.routes[0].legs[0].start_location.lng
        options.data.end_latitude = gData.routes[0].legs[0].end_location.lat
        options.data.end_longitude = gData.routes[0].legs[0].end_location.lng

        msg.send "#{options.data.end_latitude}"
      )
      .then((uUrl, options) ->
        rp(uUrl, options)
          .then((uData) ->
            msg.send "#{uData}"
        )
        .catch((uErr) ->
          errMsg = uErr.message
          errCode = uErr.statusCode
          msg.send "#{errMsg}. Code: #{errCode}."
          msg.send "Uber doesn't like your shenanigans."
        )
      )
      .catch((err) ->
        errCode = err.code
        errStatus = err.status
        errMsg = err.message
        msg.send "Error, code: #{errCode}. #{errStatus}: #{errMsg}"
        msg.send "Did you try to find directions to/in Neverland?"
      )

formatAddress = (add) ->
  add.split(" ").join("+");
