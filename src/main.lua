F = assert(SMODS.load_file("src/LuaFunctional/functional.lua"))()
assert(SMODS.load_file("src/challenge.lua"))()
assert(SMODS.load_file("src/spectral.lua"))()
assert(SMODS.load_file("src/blind.lua"))()
assert(SMODS.load_file("src/joker.lua"))()

if Balatest then
    assert(SMODS.load_file("src/tests/joker.tests.lua"))()
    assert(SMODS.load_file("src/tests/blind.tests.lua"))()
    assert(SMODS.load_file("src/tests/spectral.tests.lua"))()
end

SMODS.Joker:take_ownership("joker", {cost = 1}, true)

SMODS.Atlas {
    px = 256,
    py = 256,
    key = "modicon",
    path = "icon.png",
}
