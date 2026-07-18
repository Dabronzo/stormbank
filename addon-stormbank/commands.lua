-- Author: <Authorname> (Please change this in user settings, Ctrl+Comma)
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

require("bank")
require("displays")
require("loans")

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
        Displays.financialSituation(peer_id)
        return
    end

    if command == "?loans" then
        server.announce("StormBank", Loans.getTypesHelpText(), peer_id)
        return
    end
    
    if command == "?loan" then
        local arguments = { ... }
        Commands.handleLoan(peer_id, arguments)
        return
    end

end

Commands.handleLoan = function(peer_id, arguments)
    local amount = tonumber(arguments[1])
    local label = arguments[2]

    if not Loans.validateLoanInput(amount, label) then
        server.announce(
            "StormBank",
            "Invalid amount or loan type",
            peer_id
        )
        return
    end

    local terms = Loans.calculateLoanTerms(amount, label)
    local success, message = Bank.createLoan(
        amount,
        terms.installment,
        terms.number_of_installments
    )
    server.announce("StormBank", message, peer_id)
end
