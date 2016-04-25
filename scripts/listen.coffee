module.exports = (robot) ->


  robot.hear /uber/i, (res) ->
    res.send "Looking for an Uber? To get the latest estimates, reply to me with \"current wait\"."

  robot.respond /current wait/i, (res) ->

    url = "https://api.uber.com/v1/products"

    parameters =
      server_token: "CwEUXi7RittlCfJk38_CdjJrQ0Yeigk2B0oUPjdc"
      latitude: 37.775818
      longitude: -122.418028

    robot.http(url, parameters)
      .header('Accept', 'application/json')
      .get() (err, res, body) ->

        # err & response status checking code
        if response.getHeader('Content-Type') isnt 'application/json'
          res.send "Didn't get back JSON :("
          return

        data = null
        try
          data = JSON.parse body
        catch error
          res.send "Ran into an error parsing JSON"
          return

        for product, i in data.products
          res.send "I found #{product.display_name}"
