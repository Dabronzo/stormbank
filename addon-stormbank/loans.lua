-- Author: <Authorname> (Please change this in user settings, Ctrl+Comma)
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

Loans = {}

Loans.types = {
    standard = {
        label = "standard",
        display_name = "Standard Loan",
        installments = 12,
        interest_rate = 0.10,
        max_amount = 1000000,
    },
    quick = {
        label = "quick",
        display_name = "Quick Loan",
        installments = 6,
        interest_rate = 0.15,
        max_amount = 500000,
    },
    long = {
        label = "long",
        display_name = "Long Loan",
        installments = 24,
        interest_rate = 0.12,
        max_amount = 5000000,
    }
}

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

function Loans.calculateLoanTerms(amount, label)
    local number_of_installments = Loans.getTypes(label).installments

    local total_repayment = math.ceil(amount * 1.10)
    local installment = math.ceil(
        total_repayment / number_of_installments
    )
    return {
        number_of_installments = number_of_installments,
        installment = installment
    }
end

function Loans.getTypesHelpText()
    local lines = { "Available loan types:" }
    for _, loan_type in pairs(Loans.types) do
        table.insert(lines, string.format(
            "- %s: %d months, %.0f%% interest",
            loan_type.label,
            loan_type.installments,
            loan_type.interest_rate * 100
        ))
    end
    return table.concat(lines, "\n")
end