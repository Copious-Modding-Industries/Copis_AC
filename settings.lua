dofile("data/scripts/lib/mod_settings.lua") -- see this file for documentation on some of the features.
dofile("data/scripts/lib/utilities.lua")
local mod_id = "Copis_gun"
mod_settings_version = 1

mod_settings =
{
    {
        ui_fn = mod_setting_vertical_spacing,
        not_setting = true,
        hidden = false,
    },
}

function ModSettingsGuiCount()
    return mod_settings_gui_count(mod_id, mod_settings)
end

local function GuiQuery(gui, new_id)
    GuiLayoutBeginHorizontal(gui, mod_setting_group_x_offset, 0, false, 0, 6)
        GuiColorSetForNextWidget(gui, 0.5, 0.5, 0.5, 1.0)
        GuiText(gui, 0, 0, "Search: ")
        local query = tostring(ModSettingGetNextValue("copis_ac.query") or "")
        local query_new = GuiTextInput(gui, new_id(), 0, 0, query, 200, 100)
        if query ~= query_new then
            ModSettingSetNextValue("copis_ac.query", query_new, false)
        end
    GuiLayoutEnd(gui)
    return query
end

-- This function is called to display the settings UI for this mod. Your mod's settings wont be visible in the mod settings menu if this function isn't defined correctly.
function ModSettingsGui(gui, in_main_menu)
    screen_width, screen_height = GuiGetScreenDimensions(gui)
    mod_settings_gui(mod_id, mod_settings, gui, in_main_menu)
    id = 432534
    local function new_id() id = id + 1; return id end
    if true then --not in_main_menu then
        GuiLayoutBeginVertical(gui, mod_setting_group_x_offset, 0, false, 0, 0)

            local query = GuiQuery(gui, new_id)

            dofile_once("data/scripts/gun/gun_actions.lua")
            for index, action in ipairs(actions) do
                GuiLayoutBeginHorizontal(gui, 1, 0, false, 0, 6)
                    if GameTextGetTranslatedOrNot(action.name):upper():match(query:upper()) then
                        local state = ModSettingGetNextValue("copis_ac.state_" .. action.id)
                        GuiOptionsAddForNextWidget(gui, 28)
                        GuiOptionsAddForNextWidget(gui, 6)
                        if not state then
                            GuiOptionsAddForNextWidget(gui, 26)
                        end
                        local lmb = GuiImageButton(gui, new_id(), 0, 0, "", action.sprite)
                        if lmb then
                            ModSettingSetNextValue("copis_ac.state_" .. action.id, not state, false)
                        end
                        GuiLayoutBeginVertical(gui, 1, 0, false, 0, 10)
                            if state then
                                GuiColorSetForNextWidget(gui, 1.0, 1.0, 1.0, 1.0)
                                GuiText(gui, 0, 0, GameTextGetTranslatedOrNot(action.name))
                                GuiLayoutBeginHorizontal(gui, 0, 0, false, 0, 10)
                                    GuiImage(gui, new_id(), 0, 9.5, "mods/custom_always_cast/bool_t.png", 1, 1, 1)
                                    GuiColorSetForNextWidget(gui, 0.5, 1.0, 0.5, 1.0)
                                    GuiText(gui, 1, 8, "Spell will spawn as an always cast.")
                                GuiLayoutEnd(gui)
                            else
                                GuiColorSetForNextWidget(gui, 1.0, 1.0, 1.0, 0.5)
                                GuiText(gui, 0, 0, GameTextGetTranslatedOrNot(action.name))
                                GuiLayoutBeginHorizontal(gui, 0, 0, false, 0, 10)
                                    GuiImage(gui, new_id(), 0, 9.5, "mods/custom_always_cast/bool_f.png", 0.5, 1, 1)
                                    GuiColorSetForNextWidget(gui, 1.0, 0.5, 0.5, 0.5)
                                    GuiText(gui, 1, 8, "Spell will not spawn as an always cast.")
                                GuiLayoutEnd(gui)
                            end
                        GuiLayoutEnd(gui)
                    end
                GuiLayoutEnd(gui)
            end
        GuiLayoutEnd(gui)
    else
        GuiLayoutBeginHorizontal(gui, 0, 0, false, 5, 5)
            GuiImage(gui, new_id(), 0, 0, "data/ui_gfx/inventory/icon_warning.png", 1, 1, 1)
            GuiColorSetForNextWidget(gui, 0.9, 0.4, 0.4, 0.9)
            GuiText(gui, 0, 2, "Please open this menu in-game to change settings!")
        GuiLayoutEnd(gui)
    end
end