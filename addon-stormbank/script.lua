--- Note, minimizer functionality can be disabled in your project settings. (right click -> Folder Settings)
--- A large scale update for supporting Addon work is in the works, so keep an eye on the extension!

g_savedata = {}

require("bank")
require("commands")

function onCreate(is_created)
    Bank.initialize()
end

function onCustomCommand(full_message, peer_id, is_admin, is_auth, command, ...)
    Commands.handle(full_message, peer_id, is_admin, is_auth, command, ...)
end

function onTick(game_ticks)
    Bank.tick(game_ticks)
end