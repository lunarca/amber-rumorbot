# Description:
#   Generates quasi-deniable rumor mill for hubot
#
# Dependencies:
#   "sha1": "1.1.1"
#
# Commands:
#   register [alias] [password] - Register an alias with rumorbot
#   login [alias] [password] - log in to a given alias
#   rumor [message] - Have rumorbot spit out [message] to #rumormill
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   lunarca

sha1 = require('sha1')

module.exports = (robot) ->

    robot.respond /register (\S*) (.*)/, (res) ->
        username = res.match[1]
        password = sha1(res.match[2])

        aliases = robot.brain.get("alias-map")
        if not aliases
            aliases = {}

        if aliases[username]
            res.reply "That name is already registered."
        else
            aliases[username] = password
            res.reply "Congrats #{res.message.user.name}, you are registered as #{username}. Remember your password."

        robot.brain.set "alias-map", aliases


    robot.respond /login (\S*) (.*)/, (res) ->
        username = res.match[1]
        password = sha1(res.match[2])
        aliases = robot.brain.get("alias-map")
        if not aliases
            aliases = {}
        logins = robot.brain.get("login-map")
        if not logins
            logins= {}
        current_user = res.message.user.name

        if aliases[username]
            if password == aliases[username]
                logins[sha1(current_user)] = username
                res.reply "Logged in successfully as #{username}"
            else
                res.reply "Incorrect login for #{username}"
        else
            res.reply "That alias is not registered. Try 'register [alias] [password]' first"

        robot.brain.set "alias-map", aliases
        robot.brain.set "login-map", logins


    robot.respond /rumor (.*)/i, (res) ->
        logins = robot.brain.get("login-map")
        if not logins
            logins = {}
        current_user = res.message.user.name
        alias = logins[sha1(current_user)]
        message = res.match[1]

        if alias
            robot.messageRoom '#rumormill', "[#{alias}] #{message}"
        else
            res.reply "You are not logged in to any alias"
