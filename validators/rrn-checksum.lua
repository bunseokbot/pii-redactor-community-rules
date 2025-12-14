-- Korean Resident Registration Number (RRN) Validator
-- Validates Korean RRN using the official checksum algorithm

-- Validates a Korean RRN
-- @param value string The RRN to validate (with or without hyphen)
-- @return boolean True if valid, false otherwise
function validate(value)
    -- Remove hyphen if present
    local digits = value:gsub("-", "")

    -- RRN must be exactly 13 digits
    if #digits ~= 13 then
        return false
    end

    -- Check if all characters are digits
    if not digits:match("^%d+$") then
        return false
    end

    -- Validate birth date portion (first 6 digits)
    local year = tonumber(digits:sub(1, 2))
    local month = tonumber(digits:sub(3, 4))
    local day = tonumber(digits:sub(5, 6))

    if month < 1 or month > 12 then
        return false
    end

    if day < 1 or day > 31 then
        return false
    end

    -- Validate gender digit (7th digit)
    local gender = tonumber(digits:sub(7, 7))
    if gender < 1 or gender > 4 then
        return false
    end

    -- Checksum validation
    -- Weights: 2, 3, 4, 5, 6, 7, 8, 9, 2, 3, 4, 5
    local weights = {2, 3, 4, 5, 6, 7, 8, 9, 2, 3, 4, 5}
    local sum = 0

    for i = 1, 12 do
        sum = sum + (tonumber(digits:sub(i, i)) * weights[i])
    end

    local check_digit = (11 - (sum % 11)) % 10
    local last_digit = tonumber(digits:sub(13, 13))

    return check_digit == last_digit
end

-- Test cases
local function run_tests()
    -- Note: These are example patterns, not real RRNs
    -- The actual checksum validation would fail for random numbers

    -- Test format validation
    assert(validate("12345") == false, "Short number should fail")
    assert(validate("1234567890123456") == false, "Long number should fail")
    assert(validate("12345678901234") == false, "14 digits should fail")
    assert(validate("123456-0123456") == false, "Invalid gender digit should fail")
    assert(validate("123456-5123456") == false, "Invalid gender digit 5 should fail")

    print("All RRN validator tests passed!")
end

-- Uncomment to run tests
-- run_tests()

return {
    validate = validate,
    name = "rrn-checksum",
    description = "Korean Resident Registration Number checksum validator"
}
