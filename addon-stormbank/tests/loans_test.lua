package.path = package.path .. ";../?.lua"

require("loans")

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

test("standard loan terms", function()
    local loanType = Loans.getTypes("standard")
    assert_true(loanType ~= nil)
    local terms = Loans.calculateLoanTerms(1000, loanType)
    assert_eq(terms.installment, 92)
    assert_eq(terms.number_of_installments, 12)
end)

test("validate loan input", function()
    local loanType = Loans.getTypes("standard")
    assert_true(Loans.validateLoanInput(1000, "standard"))
    assert_false(Loans.validateLoanInput(1000, "invalid"))
    assert_false(Loans.validateLoanInput(0, "standard"))
    assert_false(Loans.validateLoanInput(nil, "standard"))
    assert_false(Loans.validateLoanInput(1000, nil))
end)

test("help text hides special loan type", function()
    local help = Loans.getTypesHelpText()

    assert_true(string.find(help, "standard") ~= nil)
    assert_true(string.find(help, "quick") ~= nil)
    assert_true(string.find(help, "long") ~= nil)
    assert_true(string.find(help, "special") == nil)
end)

print(passed .. " tests passed")