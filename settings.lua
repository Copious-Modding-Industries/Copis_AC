dofile("data/scripts/lib/mod_settings.lua") -- see this file for documentation on some of the features.
dofile("data/scripts/lib/utilities.lua")
local mod_id = "Copis_AC"
mod_settings_version = 1

mod_settings =
{
    {
        id = "spellsearch",
        ui_name = "",
        ui_fn = function(mod_id, gui, in_main_menu, im_id, setting)
            if not in_main_menu then
                GuiLayoutBeginHorizontal(gui, mod_setting_group_x_offset, 0, false, 0, 6)
                    GuiColorSetForNextWidget(gui, 1.0, 1.0, 1.0, 0.5)
                    GuiText(gui, 0, 0, "Search: ")
                    local query = tostring(ModSettingGetNextValue("Copis_AC.spellquery") or "")
                    local query_new = GuiTextInput(gui, im_id, 0, 0, query, 200, 100, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 ")
                    if query ~= query_new then
                        ModSettingSetNextValue("Copis_AC.spellquery", query_new, false)
                    end
                GuiLayoutEnd(gui)
            end
        end
    },
    {
        id = "spellsmenu",
        ui_name = "",
        ui_fn = function(mod_id, gui, in_main_menu, im_id, setting)
            GuiIdPushString(gui, "Copis_AC")
            if not in_main_menu then
                dofile_once( "data/scripts/gun/gun.lua" );
                GuiLayoutBeginHorizontal(gui, 0, 0, false, 3, 3)
                    local count = 0
                    for index, action in ipairs(actions) do
                        if GameTextGetTranslatedOrNot(action.name):upper():match((ModSettingGetNextValue("Copis_AC.spellquery") or ""):upper()) then
                            if count % 14 == 0 then
                                GuiLayoutEnd(gui)
                                GuiLayoutBeginHorizontal(gui, 0, 0, false, 3, 3)
                            end
                            local border_by_type = {
                                "data/ui_gfx/inventory/item_bg_projectile.png",
                                "data/ui_gfx/inventory/item_bg_static_projectile.png",
                                "data/ui_gfx/inventory/item_bg_modifier.png",
                                "data/ui_gfx/inventory/item_bg_draw_many.png",
                                "data/ui_gfx/inventory/item_bg_material.png",
                                "data/ui_gfx/inventory/item_bg_other.png",
                                "data/ui_gfx/inventory/item_bg_utility.png",
                                "data/ui_gfx/inventory/item_bg_passive.png",
                            }

                            GuiZSetForNextWidget(gui, 5) 
                            for _, value in ipairs({5, 28, 6}) do GuiOptionsAddForNextWidget(gui, value) end
                            GuiImage(gui, index, 0, 0, border_by_type[action.type + 1], 1, 1, 1)
                            local _, _, _, x, y= GuiGetPreviousWidgetInfo(gui)
                            local state = ModSettingGetNextValue("copis_ac.state_" .. action.id)

                            if action.never_ac then
                                GuiZSetForNextWidget(gui, 4.8)
                                for _, value in ipairs({15, 28, 6}) do GuiOptionsAddForNextWidget(gui, value) end
                                GuiImage(gui, index + #actions, x, y, "mods/copis_ac/locked.png", 1, 1, 1)

                                GuiZSetForNextWidget(gui, 4.9)
                                for _, value in ipairs({15, 28, 6, 26}) do GuiOptionsAddForNextWidget(gui, value) end
                                GuiImage(gui, index + #actions * 2, 0, 0, action.sprite, 0.5, 1, 1)
                            else
                                if not state then
                                    GuiOptionsAddForNextWidget(gui, 26)
                                else
                                    GuiOptionsAddForNextWidget(gui, 22)
                                end
                                GuiZSetForNextWidget(gui, 4.9)
                                for _, value in ipairs({15, 28, 6}) do GuiOptionsAddForNextWidget(gui, value) end
                                local toggle = GuiImageButton(gui, index + #actions * 3, x + 2, y + 2, "", action.sprite)
                                GuiTooltip(gui, action.name, action.description)
                            end

                            if toggle and not action.never_ac then
                                ModSettingSetNextValue("copis_ac.state_" .. action.id, not state, false)
                                GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos())
                            end
                            count = count + 1
                        end
                    end
                GuiLayoutEnd(gui)
            else
                GuiLayoutBeginHorizontal(gui, 0, 0, false, 5, 5)
                    GuiImage(gui, im_id, 0, 0, "data/ui_gfx/inventory/icon_warning.png", 1, 1, 1)
                    GuiColorSetForNextWidget(gui, 0.9, 0.4, 0.4, 0.9)
                    GuiText(gui, 0, 2, "Please open this menu in-game to edit always casts!")
                GuiLayoutEnd(gui)
            end
            mod_setting_tooltip(mod_id, gui, in_main_menu, setting)
            GuiIdPop(gui)
        end
    },
}
function ModSettingsGuiCount()
    return mod_settings_gui_count(mod_id, mod_settings)
end

-- This function is called to display the settings UI for this mod. Your mod's settings wont be visible in the mod settings menu if this function isn't defined correctly.
function ModSettingsGui(gui, in_main_menu)
    screen_width, screen_height = GuiGetScreenDimensions(gui)
    mod_settings_gui(mod_id, mod_settings, gui, in_main_menu)
end

function ModSettingsUpdate( init_scope )
    local old_version = mod_settings_get_version( mod_id ) -- This can be used to migrate some settings between mod versions.
    mod_settings_update( mod_id, mod_settings, init_scope )
end