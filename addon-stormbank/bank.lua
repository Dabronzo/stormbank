-- Author: <Authorname> (Please change this in user settings, Ctrl+Comma)
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey
Bank = {}

local DAYS_PER_MONTH = 30
local check_timer = 0

function Bank.initialize()
    g_savedata.bank = g_savedata.bank or {
        loan = nil
    }
end

function Bank.processLoanPayment()
    local loan = g_savedata.bank.loan

    if loan == nil then
        return
    end

    local current_day = server.getDateValue()


    while loan ~= nil and current_day >= loan.next_payment_day do
        local payment = math.min(
            loan.installment,
            loan.remaining_amount
        )

        local money = server.getCurrency()

        if money >= payment then
            server.setCurrency(
                money - payment,
                server.getResearchPoints()
            )

            loan.remaining_amount =
                loan.remaining_amount - payment

            loan.installments_remaining =
                loan.installments_remaining - 1

            server.announce(
                "StormBank",
                "Loan instalment paid: $" .. payment
            )

            if loan.remaining_amount <= 0 then
                server.announce("StormBank", "Loan fully repaid!")
                g_savedata.bank.loan = nil
                loan = nil
            end
        else
            loan.missed_payments = loan.missed_payments + 1

            server.announce(
                "StormBank",
                "Insufficient funds for loan instalment."
            )
        end

        if loan ~= nil then
            loan.next_payment_day =
                loan.next_payment_day + DAYS_PER_MONTH
        end
    end
end

function Bank.createLoan(
    amount,
    installment,
    number_of_installments)

    if g_savedata.bank.loan ~= nil then
        return false, "You already have a loan"
    end

    server.setCurrency(
        server.getCurrency() + amount,
        server.getResearchPoints()
    )

    g_savedata.bank.loan = {
        original_amount = amount,
        remaining_amount = installment * number_of_installments,
        installment = installment,
        installments_remaining = number_of_installments,
        next_payment_day = server.getDateValue() + DAYS_PER_MONTH,
        missed_payments = 0
    }

    return true, "Loan created successfully"
end

function Bank.tick(game_ticks)
    check_timer = check_timer + game_ticks

    -- Avoid checking on every game tick
    if check_timer < 3600 then
        return
    end

    check_timer = 0
    Bank.processLoanPayment()
end