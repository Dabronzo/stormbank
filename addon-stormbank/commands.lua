-- Author: <Authorname> (Please change this in user settings, Ctrl+Comma)
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

require("bank")
require("displays")

Commands = {}

Commands.handle = function(
    full_message,
    peer_id,
    is_admin,
    is_auth,
    command,
    ...
)

    if command == "?bank" then
        Displays.loanStatus(peer_id)
        return
    end
    
    if command ~= "?loan" then
        return
    end


    local arguments = { ... }
    local amount = tonumber(arguments[1])

    if amount == nil or amount <= 0 then
        server.announce(
            "StormBank",
            "Usage: ?loan <amount>",
            peer_id
        )
        return
    end

    -- Initial fixed loan terms: 10% interest over 10 months
    local number_of_installments = 10
    local total_repayment = math.ceil(amount * 1.10)
    local installment = math.ceil(
        total_repayment / number_of_installments
    )

    local success, message = Bank.createLoan(
        amount,
        installment,
        number_of_installments
    )

    server.announce("StormBank", message, peer_id)
end