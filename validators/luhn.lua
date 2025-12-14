-- Luhn Algorithm Validator
-- Used for credit card numbers, ITIN, and other numeric identifiers

-- Validates a number string using the Luhn algorithm
-- @param value string The numeric string to validate
-- @return boolean True if valid, false otherwise
function validate(value)
    -- Remove any non-digit characters
    local digits = value:gsub("%D", "")

    if #digits == 0 then
        return false
    end

    local sum = 0
    local is_second = false

    -- Process from right to left
    for i = #digits, 1, -1 do
        local d = tonumber(digits:sub(i, i))

        if is_second then
            d = d * 2
            if d > 9 then
                d = d - 9
            end
        end

        sum = sum + d
        is_second = not is_second
    end

    return (sum % 10) == 0
end

-- Test cases
local function run_tests()
    -- Valid credit card numbers (test numbers)
    assert(validate("4532015112830366") == true, "Visa test failed")
    assert(validate("5425233430109903") == true, "Mastercard test failed")
    assert(validate("374245455400126") == true, "Amex test failed")

    -- Invalid numbers
    assert(validate("1234567890123456") == false, "Invalid number test failed")
    assert(validate("0000000000000000") == true, "Zero test failed") -- All zeros passes Luhn

    -- With formatting
    assert(validate("4532-0151-1283-0366") == true, "Formatted number test failed")

    print("All Luhn validator tests passed!")
end

-- Uncomment to run tests
-- run_tests()

return {
    validate = validate,
    name = "luhn",
    description = "Luhn algorithm checksum validator"
}
