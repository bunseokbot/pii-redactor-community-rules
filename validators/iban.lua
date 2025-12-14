-- IBAN (International Bank Account Number) Validator
-- Validates IBAN using the MOD-97 algorithm per ISO 13616

-- Country-specific IBAN lengths
local IBAN_LENGTHS = {
    AL = 28, AD = 24, AT = 20, AZ = 28, BH = 22, BY = 28, BE = 16, BA = 20,
    BR = 29, BG = 22, CR = 22, HR = 21, CY = 28, CZ = 24, DK = 18, DO = 28,
    EG = 29, SV = 28, EE = 20, FO = 18, FI = 18, FR = 27, GE = 22, DE = 22,
    GI = 23, GR = 27, GL = 18, GT = 28, HU = 28, IS = 26, IQ = 23, IE = 22,
    IL = 23, IT = 27, JO = 30, KZ = 20, XK = 20, KW = 30, LV = 21, LB = 28,
    LI = 21, LT = 20, LU = 20, MK = 19, MT = 31, MR = 27, MU = 30, MC = 27,
    MD = 24, ME = 22, NL = 18, NO = 15, PK = 24, PS = 29, PL = 28, PT = 25,
    QA = 29, RO = 24, LC = 32, SM = 27, ST = 25, SA = 24, RS = 22, SC = 31,
    SK = 24, SI = 19, ES = 24, SE = 24, CH = 21, TL = 23, TN = 24, TR = 26,
    UA = 29, AE = 23, GB = 22, VA = 22, VG = 24
}

-- Convert a character to its numeric value (A=10, B=11, etc.)
local function char_to_num(c)
    if c:match("%d") then
        return c
    else
        return tostring(string.byte(c:upper()) - 55)
    end
end

-- Perform MOD-97 on a large number represented as string
local function mod97(num_str)
    local remainder = 0
    for i = 1, #num_str do
        local digit = tonumber(num_str:sub(i, i))
        remainder = (remainder * 10 + digit) % 97
    end
    return remainder
end

-- Validates an IBAN
-- @param value string The IBAN to validate
-- @return boolean True if valid, false otherwise
function validate(value)
    -- Remove spaces and convert to uppercase
    local iban = value:gsub("%s", ""):upper()

    -- Check minimum length
    if #iban < 15 then
        return false
    end

    -- Extract country code
    local country = iban:sub(1, 2)

    -- Check if country is known and length matches
    local expected_length = IBAN_LENGTHS[country]
    if expected_length and #iban ~= expected_length then
        return false
    end

    -- Check basic format: 2 letters + 2 digits + alphanumeric
    if not iban:match("^%a%a%d%d[%w]+$") then
        return false
    end

    -- Rearrange: move first 4 characters to end
    local rearranged = iban:sub(5) .. iban:sub(1, 4)

    -- Convert letters to numbers
    local numeric = ""
    for i = 1, #rearranged do
        numeric = numeric .. char_to_num(rearranged:sub(i, i))
    end

    -- Validate checksum (MOD 97 should equal 1)
    return mod97(numeric) == 1
end

-- Test cases
local function run_tests()
    -- Valid IBANs (test numbers)
    assert(validate("GB82 WEST 1234 5698 7654 32") == true, "UK IBAN test failed")
    assert(validate("DE89370400440532013000") == true, "German IBAN test failed")
    assert(validate("FR1420041010050500013M02606") == true, "French IBAN test failed")

    -- Invalid IBANs
    assert(validate("GB82WEST12345698765433") == false, "Invalid checksum should fail")
    assert(validate("XX00TEST") == false, "Short IBAN should fail")
    assert(validate("1234567890") == false, "No country code should fail")

    print("All IBAN validator tests passed!")
end

-- Uncomment to run tests
-- run_tests()

return {
    validate = validate,
    name = "iban",
    description = "IBAN (International Bank Account Number) validator using MOD-97"
}
