assert(SMODS.load_file("src/LuaFunctional/functional.lua"))()
assert(SMODS.load_file("src/challenge.lua"))()
assert(SMODS.load_file("src/joker.lua"))()

SMODS.Atlas {
    path = "Icon.png",
    key = "modicon",
    px = 256,
    py = 256,
}
