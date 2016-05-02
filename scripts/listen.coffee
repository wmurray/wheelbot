rp = require("request-promise")

formatAddress = (add) ->
  return add.split(" ").join("+")

uriConcat = (apiInfo, msg) ->
  concatUri = apiInfo.base
  queryStrings = apiInfo.queryStrings
  queryValues = apiInfo.values


  msg.send "#{queryValues}, #{concatUri}"
  for i in queryStrings
    concatUri = concatUri + queryStrings[i] + queryValues[i]

  return concatUri

module.exports = (robot) ->

  robot.respond /get me from (.*) to (.*)/i, (msg) ->
    origin = formatAddress(msg.match[1])
    destination = formatAddress(msg.match[2])

    msg.send "#{origin}"

    gInfo =
      base: "https://maps.googleapis.com/maps/api/directions/json"
      queryStrings: ["?origin=", "&destination=", "&key="]
      values: [origin, destination]
      key: process.env.GOOGLE_MAPS_TOKEN

    uInfo =
      base: "http://api.uber.com/v1/estimates/prices"
      queryStrings: ["?start_latitude=", "&start_longitude=", "&end_latitude=", "&end_longitude="]
      values: []
      key: process.env.UBER_SERVER_TOKEN


    googOpts =
      uri: uriConcat(gInfo, msg)
      headers:
        "User-Agent": "Request-Promise"
      json: true

    uOpts =
      uri: ""
      headers:{
        "Authorization": "Token " + uInfo.key
      }
      json: true

    rp()
      .then((gData) ->
        uInfo.values.push(
          gData.routes[0].legs[0].start_location.lat,
          gData.routes[0].legs[0].start_location.lng,
          gData.routes[0].legs[0].end_location.lat,
          gData.routes[0].legs[0].end_location.lng
        )

        uOpts.url = uriConcat(uInfo)

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
