---@class LoanType
---@field label string
---@field display_name string
---@field installments integer
---@field interest_rate number
---@field max_amount integer
---@field days_per_payment integer
---@field hidden_from_help boolean|nil
---@class LoanTerms
---@field number_of_installments integer
---@field installment integer
---@field days_per_payment integer
---@type table<string, LoanType>

Loans = {}

Loans.types = {
    standard = {
        label = "standard",
        display_name = "Standard Loan",
        installments = 12,
        interest_rate = 0.10,
        max_amount = 1000000,
        days_per_payment = 30,
    },
    quick = {
        label = "quick",
        display_name = "Quick Loan",
        installments = 6,
        interest_rate = 0.08,
        max_amount = 500000,
        days_per_payment = 30,
    },
    long = {
        label = "long",
        display_name = "Long Loan",
        installments = 24,
        interest_rate = 0.3,
        max_amount = 5000000,
        days_per_payment = 30,
    },
    special = {
        label = "special",
        display_name = "Special Loan",
        installments = 2,
        interest_rate = 0.5,
        max_amount = 5000000,
        days_per_payment = 1,
        hidden_from_help = true,
    }
}

---@param label string
---@return LoanType|nil
function Loans.getTypes(label)
    if label == nil then
        return nil
    end

    return Loans.types[string.lower(label)]
end

function Loans.validateLoanInput(amount, label)
    if amount == nil or amount <= 0 then
        return false
    end

    local loan_type = Loans.getTypes(label)
    if loan_type == nil then
        return false
    end

    if amount > loan_type.max_amount then
        return false
    end

    return true
end

---@param amount number
---@param loan LoanType
---@return LoanTerms
function Loans.calculateLoanTerms(amount, loan)

    local number_of_installments = loan.installments

    local total_repayment = math.ceil(amount * (1 + loan.interest_rate))
    local installment = math.ceil(
        total_repayment / number_of_installments
    )
    return {
        number_of_installments = number_of_installments,
        installment = installment,
        days_per_payment = loan.days_per_payment
    }
end

function Loans.getTypesHelpText()
    local lines = { "Available loan types:" }
    for _, loan_type in pairs(Loans.types) do
        if not loan_type.hidden_from_help then
            table.insert(lines, string.format(
                "- %s: %d payments, %.0f%% interest, each %d days",
                loan_type.label,
                loan_type.installments,
                loan_type.interest_rate * 100,
                loan_type.days_per_payment
            ))
        end
    end
    return table.concat(lines, "\n")
end