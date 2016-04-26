module.exports = (robot) ->

  robot.respond /googlemaps/i, (res) ->
    res.reply "#{process.env.GOOGLE_MAPS_TOKEN}"

  robot.hear /uber/i, (res) ->
    res.send "Looking for an Uber? To get the latest estimates, reply to me with \"current wait\"."

  robot.respond /current wait/i, (res) ->
    res.reply "Soon."
