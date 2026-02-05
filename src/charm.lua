local _, q = unpack(... or require "src.functional")

SMODS.Atlas {
    key = "iphone",
    path = "iphone.png",
    px = 68,
    py = 68,
}

q(function()
    local current_mod = SMODS.current_mod
    SMODS.current_mod = SMODS.Mods.Roland

    local charm = Bakery_API.Charm {
        key = "iphone",
        atlas = "iphone",
        pos = {x = 0, y = 0},
        calculate = function(_, _, context)
            local _ = context.skip_blind and q(function()
                G.blind_prompt_box = G.blind_prompt_box and G.blind_prompt_box:remove()
                G.blind_select = G.blind_select and G.blind_select:remove()
                G.round_eval = G.round_eval and G.round_eval:remove()
                G.GAME.current_round.jokers_purchased = 0
                G.STATE = G.STATES.SHOP
                G.GAME.shop_free = nil
                G.GAME.shop_d6ed = nil
                G.STATE_COMPLETE = false
            end)
        end,
    }

    charm:inject()
    charm:process_loc_text()
    SMODS._save_d_u(charm)
    SMODS.current_mod = current_mod
end)
