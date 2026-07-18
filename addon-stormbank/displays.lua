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
        "loan: $", loan.original_amount,
        "remain: $", loan.remaining_amount,
        "Instal: $", loan.installment,
        "Left: ", loan.installments_remaining,
        "Nextpay: ", days_until,
        "Missed: ", loan.missed_payments,
    }, "\n")
end

function Displays.initialize()
    g_savedata.displays = g_savedata.displays or {
        isPopupOpen = false
    }
end

function Displays.financialSituation(peer_id)
    local account_id = g_savedata.bank.account_id
    if g_savedata.displays.isPopupOpen then
        server.setPopupScreen(
            peer_id,
            account_id,
            "StormBank",
            false,
            "",
            0,    -- center horizontally
            0.3   -- slightly above center
        )
        g_savedata.displays.isPopupOpen = false
        return
    end
    g_savedata.displays.isPopupOpen = true
    local text = Displays.getFinancialSituation()
    server.setPopupScreen(
        peer_id,
        account_id,
        "StormBank",
        true,
        text,
        0,    -- center horizontally
        0.3   -- slightly above center
    )
end