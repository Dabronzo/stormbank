Displays = {}

function Displays.getFinancialSituation()
    local loan = g_savedata.bank.loan
    if loan == nil then
        return "No loan"
    end
    local days_until = math.max(0, math.ceil(loan.next_payment_day - server.getDateValue()))
    return table.concat({
        "LOAN STATUS",
        "-------------",
        "Balance: $", server.getCurrency(),
        "original amount: $", loan.original_amount,
        "remaining amount: $", loan.remaining_amount,
        "Amount per installment: $", loan.installment,
        "installments remaining: ", loan.installments_remaining,
        "days until next payment: ", days_until,
        "missed payments: ", loan.missed_payments,
    }, "\n")
end

function Displays.getCommandsHelpText()
    return table.concat({
        "Commands:",
        "?bank - get financial situation",
        "?loans - get loans help text",
        "?loan <amount> <loan type> - create a loan",
        "?repay - repay a loan",
    }, "\n")
end