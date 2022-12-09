local actions_to_edit = {
    "RESET",
    "IF_ENEMY",
    "IF_PROJECTILE",
    "IF_HP",
    "IF_HALF",
    "IF_END",
    "IF_ELSE",
    "SUMMON_PORTAL",
    "ALL_SPELLS",
    "ALL_NUKES",
    "ALL_DISCS",
    "ALL_ROCKETS",
    "ALL_DEATHCROSSES",
    "ALL_BLACKHOLES",
    "ALL_ACID",
}

for i, current_action in ipairs(actions) do
    for e, action_to_edit in ipairs(actions_to_edit) do
        if current_action.id == action_to_edit then
            table.remove( actions_to_edit, e )
            current_action.never_ac = true
            break
        end
    end
end