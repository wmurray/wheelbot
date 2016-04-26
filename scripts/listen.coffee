Uber = require('uber-api')
    server_token: "CwEUXi7RittlCfJk38_CdjJrQ0Yeigh2B0oUPjdc"


module.exports = (robot) ->


  robot.hear /uber/i, (res) ->
    res.send "Looking for an Uber? To get the latest estimates, reply to me with \"current wait\"."

  robot.respond /current wait/i, (res) ->

    url = "https://api.uber.com/v1/products"

    parameters =
      latitude: 37.775818
      longitude: -122.418028
