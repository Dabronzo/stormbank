
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
        local text = Displays.getFinancialSituation()
        server.announce("StormBank", text, peer_id)
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

    if command == "?repay" then
        local success, message = Bank.fullRepayLoan()
        if success then
            server.announce("StormBank", message, peer_id)
            return
        end
        server.announce("StormBank", message, peer_id)
        return
    end

    if command == "?help" then
        server.announce("StormBank", Displays.getCommandsHelpText(), peer_id)
        return
    end

end

Commands.handleLoan = function(peer_id, arguments)
    local amount = tonumber(arguments[1])
    local label = arguments[2]
    local loanType = Loans.getTypes(label)

    if not Loans.validateLoanInput(amount, label) then
        server.announce(
            "StormBank",
            "Invalid amount or loan type",
            peer_id
        )
        return
    end

    if loanType == nil or amount == nil then
        server.announce(
            "StormBank",
            "amount or loan type cannot be null",
            peer_id
        )
        return
    end

    local terms = Loans.calculateLoanTerms(amount, loanType)
    local success, message = Bank.createLoan(
        amount,
        terms.installment,
        terms.number_of_installments,
        terms.days_per_payment
    )
    server.announce("StormBank", message, peer_id)
end
