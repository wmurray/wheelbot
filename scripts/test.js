module.exports = function(robot){

  robot.respond(/javascript/i, function(msg){
    msg.reply("Yes, I know that.");
  });

}
