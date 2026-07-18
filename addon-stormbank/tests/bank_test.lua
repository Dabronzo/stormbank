package.path = package.path .. ";../?.lua"

server = {
    _money = 0,
    _day = 0,
    getCurrency = function() return server._money end,
    setCurrency = function(money, _)
        server._money = money
    end,
    getResearchPoints = function() return 0 end,
    getDateValue = function() return server._day end,
    announce = function() end,
    getMapID = function() return 1 end,
}

g_savedata = {}

require("bank")

local passed = 0

local function test(name, fn)
    fn()
    passed = passed + 1
    print("OK: " .. name)
end

local function assert_true(v, msg)
    if not v then error(msg or "expected true") end
end

local function assert_false(v, msg)
    if v then error(msg or "expected false") end
end

local function assert_eq(a, b, msg)
    if a ~= b then
        error((msg or "not equal") .. ": " .. tostring(a) .. " ~= " .. tostring(b))
    end
end

local function reset_bank(money, day)
    server._money = money or 0
    server._day = day or 0
    g_savedata = {}
    Bank.initialize()
end

local function create_standard_loan(amount)
    amount = amount or 1000
    local installment = 92
    local installments = 12
    local days_per_payment = 30

    local success, message = Bank.createLoan(
        amount,
        installment,
        installments,
        days_per_payment
    )

    return success, message, {
        amount = amount,
        installment = installment,
        installments = installments,
        days_per_payment = days_per_payment,
        total_repayment = installment * installments,
    }
end

test("initialize bank", function()
    reset_bank()

    assert_true(g_savedata.bank ~= nil)
    assert_false(g_savedata.bank.account_id == nil)
    assert_eq(g_savedata.bank.loan, nil)
end)

test("create loan", function()
    reset_bank()

    local success, message, terms = create_standard_loan(1000)

    assert_true(success)
    assert_eq(message, "Loan created successfully")
    assert_true(g_savedata.bank.loan ~= nil)
    assert_eq(g_savedata.bank.loan.original_amount, terms.amount)
    assert_eq(g_savedata.bank.loan.remaining_amount, terms.total_repayment)
    assert_eq(g_savedata.bank.loan.installment, terms.installment)
    assert_eq(g_savedata.bank.loan.installments_remaining, terms.installments)
    assert_eq(g_savedata.bank.loan.days_per_payment, terms.days_per_payment)
    assert_eq(g_savedata.bank.loan.next_payment_day, server._day + terms.days_per_payment)
    assert_eq(g_savedata.bank.loan.missed_payments, 0)
end)

test("create loan adds borrowed amount to balance", function()
    reset_bank(500)

    local success = create_standard_loan(1000)

    assert_true(success)
    assert_eq(server._money, 1500)
end)

test("reject second loan", function()
    reset_bank()

    local success = create_standard_loan(1000)
    assert_true(success)

    local second_success, message = Bank.createLoan(500, 50, 10, 30)

    assert_false(second_success)
    assert_eq(message, "You already have a loan")
end)

test("process payment deducts installment", function()
    reset_bank(1000)

    create_standard_loan(1000)
    server._day = g_savedata.bank.loan.next_payment_day

    Bank.processLoanPayment()

    assert_eq(server._money, 2000 - 92)
    assert_eq(g_savedata.bank.loan.remaining_amount, 1104 - 92)
    assert_eq(g_savedata.bank.loan.installments_remaining, 11)
    assert_eq(
        g_savedata.bank.loan.next_payment_day,
        server._day + g_savedata.bank.loan.days_per_payment
    )
end)

test("process payment records missed payment when funds are insufficient", function()
    reset_bank(0)

    create_standard_loan(1000)
    server._money = 10
    server._day = g_savedata.bank.loan.next_payment_day

    Bank.processLoanPayment()

    assert_eq(server._money, 10)
    assert_eq(g_savedata.bank.loan.remaining_amount, 1104)
    assert_eq(g_savedata.bank.loan.missed_payments, 1)
    assert_eq(
        g_savedata.bank.loan.next_payment_day,
        server._day + g_savedata.bank.loan.days_per_payment
    )
end)

test("fully repaid loan is cleared", function()
    reset_bank(100)

    Bank.createLoan(100, 100, 1, 30)
    server._day = g_savedata.bank.loan.next_payment_day

    Bank.processLoanPayment()

    assert_eq(g_savedata.bank.loan, nil)
    assert_eq(server._money, 100)
end)

test("full repay loan with no active loan fails", function()
    reset_bank(1000)

    local success, message = Bank.fullRepayLoan()

    assert_false(success)
    assert_eq(message, "No loan to repay")
    assert_eq(g_savedata.bank.loan, nil)
    assert_eq(server._money, 1000)
end)

test("full repay loan fails with insufficient funds", function()
    reset_bank(0)

    create_standard_loan(1000)

    local success, message = Bank.fullRepayLoan()

    assert_false(success)
    assert_eq(message, "Insufficient funds to repay loan")
    assert_true(g_savedata.bank.loan ~= nil)
    assert_eq(g_savedata.bank.loan.remaining_amount, 1104)
    assert_eq(server._money, 1000)
end)

test("full repay loan clears loan and deducts remaining balance", function()
    reset_bank(500)

    local _, _, terms = create_standard_loan(1000)

    local success, message = Bank.fullRepayLoan()

    assert_true(success)
    assert_eq(message, "Loan repaid successfully")
    assert_eq(g_savedata.bank.loan, nil)
    assert_eq(server._money, 1500 - terms.total_repayment)
end)

print(passed .. " tests passed")
