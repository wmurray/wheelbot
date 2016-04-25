module.exports = (robot) =>

  robot.hear /uber/i, (res) =>
    res.send "Looking for an Uber? To get the latest estimates, reply to me with \"What's the wait?\""
