Uber = require('uber-api')
    server_token: ""


module.exports = (robot) ->


  robot.hear /uber/i, (res) ->
    res.send "Looking for an Uber? To get the latest estimates, reply to me with \"current wait\"."

  robot.respond /current wait/i, (res) ->
    res.reply "Soon."
