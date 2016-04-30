rp = require("request-promise")

module.exports = (robot) ->

  robot.respond /get me from (.*) to (.*)/i, (msg) ->
    origin = msg.match[1]
    destination = msg.match[2]
    formattedAddresses = [formatAddress(origin), formatAddress(destination)]

    gKey = process.env.GOOGLE_MAPS_TOKEN
    gBase = "https://maps.googleapis.com/maps/api/directions/json"
    gUrl = uriConcat(formattedAddresses, google)

    uBase = "http://api.uber.com/v1/estimates/prices"

    tripData = []

    googOpts =
      uri: gUrl
      headers:
        "User-Agent": "Request-Promise"
      json: true

    uOpts =
      uri: ""
      headers:{
        "Authorization": "Token " + process.env.UBER_SERVER_TOKEN
      }
      json: true

  rp(googOpts)
    .then((gData) ->
      tripData.push(
        gData.routes[0].legs[0].start_location.lat,
        gData.routes[0].legs[0].start_location.lng,
        gData.routes[0].legs[0].end_location.lat,
        gData.routes[0].legs[0].end_location.lng
      )

      uOpts.url = uriConcat(tripData, uber)

      rp(uOpts)
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

queryBuilder = (params, type) ->
  concatUri = ""
  if type == "google"
    concatUri = gBase + "?origin=" + params[0] + "&destination=" + params[1] + "&key=" + gKey
  else if type == "uber"
    concatUri = uBase + "?start_latitude=" + params[0] + "&start_longitude=" params[1] + "&end_latitude=" + params[2] + "&end_longitude=" + params[3]

  return concatUri
