rp = require("request-promise")

formatAddress = (add) ->
  return add.split(" ").join("+")

uriConcat = (apiInfo, msg) ->
  concatUri = apiInfo.base
  queryStrings = apiInfo.queryStrings
  queryValues = apiInfo.values

  stringConcat = (i) ->
    concatUri = concatUri + queryStrings[i] + queryValues[i]

  stringConcat(i) for i in [0...queryStrings.length] by 1

  return concatUri

module.exports = (robot) ->

  robot.respond /get me from (.*) to (.*)/i, (msg) ->
    origin = formatAddress(msg.match[1])
    destination = formatAddress(msg.match[2])

    gInfo =
      base: "https://maps.googleapis.com/maps/api/directions/json"
      key: process.env.GOOGLE_MAPS_TOKEN
      queryStrings: ["?origin=", "&destination=", "&key="]
      values: [origin, destination, process.env.GOOGLE_MAPS_TOKEN]

    uInfo =
      base: "http://api.uber.com/v1/estimates/prices"
      key: process.env.UBER_SERVER_TOKEN
      queryStrings: ["?start_latitude=", "&start_longitude=", "&end_latitude=", "&end_longitude="]
      values: []

    googOpts =
      uri: uriConcat(gInfo)
      headers:
        "User-Agent": "Request-Promise"
      json: true

    uOpts =
      uri: ""
      headers:{
        "Authorization": "Token " + uInfo.key
      }
      json: true

    rp(googOpts)
      .then((gData) ->
        uInfo.values.push(
          gData.routes[0].legs[0].start_location.lat,
          gData.routes[0].legs[0].start_location.lng,
          gData.routes[0].legs[0].end_location.lat,
          gData.routes[0].legs[0].end_location.lng
        )

        uOpts.uri = uriConcat(uInfo)

        msg.send "#{uOpts.uri}"

        rp(uOpts)
          .then((uData) ->
            allProducts = uData.products
            if allProducts.length > 0
              msg.send "There are #{allProducts.length} Uber products near you."
            else
              msg.send "Sorry, Uber isn't available there at this time."
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
