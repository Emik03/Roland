local function common_hand()
    return (G.GAME or {}).current_round and F.reduce(
        G.GAME.hands,
        {name = "High Card", order = -1 / 0, played = 0},
        function (a, v, k)
            return (a.played < v.played or (a.played == v.played) and (a.order > v.order)) and
                {name = k, order = v.order, played = v.played} or a
        end,
        pairs
    ).name or "High Card"
end

local function destructible(card)
    return not card.highlighted and not (card.ability or {}).eternal
end

SMODS.Atlas {
    key = "Escapey",
    path = "Escapey.png",
    px = 71,
    py = 95
}

SMODS.Joker {
    key = "Escapey",
    atlas = "Escapey",
    pos = {x = 0, y = 0},
    sinis = {x = 2, y = 0},
    soul_pos = {x = 1, y = 0},
    config = {extra = {level_up_by = 1}},
    cost = 8,
    rarity = 3,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_vars = function(_, _, center)
        local quotes = G.localization.descriptions.Joker.j_Roland_Escapey.quotes
        local normal = (Jen or {}).sinister and {} or quotes.normal[math.random(#quotes.normal)]
        local scared = (Jen or {}).sinister and quotes.scared[math.random(#quotes.scared)] or {}

        return {vars = {
            center.ability.extra.level_up_by,
            localize(common_hand(), "poker_hands"),
            normal[1] or "",
            scared[1] or "",
            normal[2] or "",
            scared[2] or ""
        }}
    end,
    Bakery_can_use = function(_, card)
        return not card.debuff and (#G.GAME.tags ~= 0 or F.any(G.consumeables.cards, destructible))
    end,
    Bakery_use_joker = function(_, card)
        local hand, destroyed = common_hand(), 0

        local function update(name, chip, mul, lv, notif, snd, vol, pit, de)
            update_hand_text({
                sound = type(snd) == "string" and snd or type(snd) == "nil" and "button",
                volume = vol or 0.7,
                pitch = pit or 0.8,
                delay = de or 0.3
            }, {
                handname = name or "????",
                chips = chip or "?",
                level = lv or "?",
                mult = mul or "?",
                StatusText = notif
            })
        end

        local function fast_nope(v)
            return function ()
                attention_text({
                    text = "NOPE",
                    colour = G.C.WHITE,
                    scale = 0.7,
                    hold = 0.3 / G.SETTINGS.GAMESPEED,
                    cover = v.HUD_tag,
                    cover_colour = G.C.BLACK,
                    align = "cm",
                })

                play_sound("cancel", 1.66, 0.5)
                v.HUD_tag.states.visible = false
                v:remove()
                return true
            end
        end

        if hand == "all" or hand == "allhands" or hand == "all_hands" then
            update(localize("k_all_hands"), "...", "...", "", notify)
        elseif G.GAME.hands[hand or "NO_HAND_SPECIFIED"] then
            update(
                localize(hand, "poker_hands"),
                G.GAME.hands[hand].chips,
                G.GAME.hands[hand].mult,
                G.GAME.hands[hand].level,
                notify
            )
        end

        F.foreach(
            F.filter(G.consumeables.cards, destructible),
            function (v)
                v:start_dissolve({HEX("57ecab")}, nil, 1.6)
                destroyed = destroyed + 1
            end
        )

        F.foreach(
            G.GAME.tags,
            function (v)
                G.E_MANAGER:add_event(Event({trigger = "immediate", func = fast_nope(v)}))
                destroyed = destroyed + 1
            end
        )

        level_up_hand(card, hand, nil, destroyed * card.ability.extra.level_up_by)

        update_hand_text(
            {sound = "button", volume = 0.7, pitch = 1.1, delay = 0},
            {mult = 0, chips = 0, handname = "", level = ""}
        )
    end,
    Bakery_use_button_text = function(_, _) return "ESCAPE" end
}

Bakery_API.usable_jokers.j_Roland_Escapey = true
