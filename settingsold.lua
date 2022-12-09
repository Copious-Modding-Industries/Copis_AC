function ModSettingsGuiCount() return 1 end
dofile_once("data/scripts/lib/utilities.lua")
dofile_once("data/scripts/lib/mod_settings.lua")
dofile_once("data/scripts/gun/gun_actions.lua")

local custom_always_cast_settings = {}

function ModSettingsUpdate(init_scope)
  local hidden_states = {}
  for i, setting in ipairs(custom_always_cast_settings) do
    hidden_states[setting.id] = setting.hidden
  end
  custom_always_cast_settings = {}
  for i, action in ipairs(actions) do
    local setting = {
      id = action.id,
      type = "action",
      name = action.name,
      desc = action.description,
      icon = action.sprite,
      key = "custom_always_cast.action_" .. action.id,
      hidden = hidden_states[action.id] or false
    }
    table.insert(custom_always_cast_settings, setting)
    if (ModSettingGet(setting.key) == nil) then
      ModSettingSet(setting.key, true)
    end
  end

  table.sort(custom_always_cast_settings, function(a, b)
    return GameTextGetTranslatedOrNot(a.name)
      < GameTextGetTranslatedOrNot(b.name)
  end)

  local frequency = {
    id = "FREQUENCY",
    type = "frequency",
    name = "frequency",
    key = "custom_always_cast.frequency",
    hidden = false
  }
  table.insert(custom_always_cast_settings, frequency)
  if (ModSettingGet(frequency.key) == nil) then
    ModSettingSet(frequency.key, 100)
  end

  -- update everything
  for _, setting in ipairs(custom_always_cast_settings) do
    if (setting.type == "action") then
      ModSettingSet(setting.key, ModSettingGetNextValue(setting.key))
    elseif (setting.type == "frequency") then
      ModSettingSet(setting.key, ModSettingGet(setting.key))
    end
  end
end

---------- render ----------

local filter_text = ""
function ModSettingsGui(gui, in_main_menu)
  local _id = 0
  local function id()
    _id = _id + 1
    return _id
  end

  -- top area
  GuiOptionsAdd(gui, GUI_OPTION.DrawActiveWidgetCursorOnBothSides)

  GuiColorSetForNextWidget(gui, 1, 1, 1, 0.5)
  GuiText(gui, 0, 0, "Set the frequency of wands that spawn with Always Cast")
  GuiLayoutBeginHorizontal(gui, 0, 0)
  GuiText(gui, 0, 0, "Frequency:   ")
  local frequency = ModSettingGet("custom_always_cast.frequency")
  if (frequency == nil) then
    frequency = 100
  end
  local next_value = GuiSlider(gui, id(), -2, 0, "", frequency, 0, 100, 100, 1, " $0% ", 64)
  if(next_value ~= frequency) then
    ModSettingSet("custom_always_cast.frequency", next_value)
  end
  GuiLayoutEnd(gui)

  GuiColorSetForNextWidget(gui, 1, 1, 1, 0.5)
  GuiText(gui, 0, 0, "Set the pool of spells that can be an Always Cast")

  GuiLayoutBeginHorizontal(gui, 0, 0)
  GuiText(gui, 0, 0, "Search spells:   ")
  local filter = GuiTextInput(gui, id(), 0, 0, filter_text, 130, 30)
  GuiLayoutEnd(gui)

  GuiLayoutBeginHorizontal(gui, 0, 0)
  local clicked_clear_filter = GuiButton(gui, id(), 0, 0, "Clear search")
  GuiText(gui, 0, 0, "     ")
  local clicked_all_on = GuiButton(gui, id(), 0, 0, "All on")
  GuiText(gui, 0, 0, "  ")
  local clicked_all_off = GuiButton(gui, id(), 0, 0, "All off")
  GuiLayoutEnd(gui)

  GuiOptionsRemove(gui, GUI_OPTION.DrawActiveWidgetCursorOnBothSides)

  if clicked_clear_filter then
    filter = ""
  elseif clicked_all_on then
    for _, setting in ipairs(custom_always_cast_settings) do
      if (string.find(setting.key, "action_") ~= nil) then
        ModSettingSetNextValue(setting.key, true, false)
      end
    end
  elseif clicked_all_off then
    for _, setting in ipairs(custom_always_cast_settings) do
      if (string.find(setting.key, "action_") ~= nil) then
        ModSettingSetNextValue(setting.key, false, false)
      end
    end
  end
  
  if filter ~= filter_text then
    filter_text = filter
    if filter == "" then
      for _, setting in ipairs(custom_always_cast_settings) do setting.hidden = false end
    else
      filter = filter:lower()
      for _, setting in ipairs(custom_always_cast_settings) do
        setting.hidden = not ((
          GameTextGetTranslatedOrNot(setting.name):lower():find(filter, 0, true)
            or setting.id:lower():find(filter, 0, true)
            or GameTextGetTranslatedOrNot(setting.desc):lower():find(filter, 0, true)
        ) and true or false)
      end
    end
  end

  -- begin main area
  GuiLayoutBeginHorizontal(gui, 0, 0)

  -- icons and labels (left)
  GuiText(gui, 0, 0, "     ") -- space for icons
  GuiLayoutBeginVertical(gui, 0, 0)
  for _, setting in ipairs(custom_always_cast_settings) do
    if not setting.hidden and setting.type == "action" then
      local value = ModSettingGetNextValue(setting.key)
      local name = GameTextGetTranslatedOrNot(setting.name)
      local desc = GameTextGetTranslatedOrNot(setting.desc)

      GuiOptionsAddForNextWidget(gui, GUI_OPTION.Layout_InsertOutsideLeft)
      GuiImage(gui, id(), -3, -2, setting.icon, 1, 1, 0)
      GuiColorSetForNextWidget(gui, 1, 1, 1, 1)
      GuiText(gui, 0, 0, name)
      GuiTooltip(gui, name, desc)
      GuiLayoutAddVerticalSpacing(gui, 5)
    end
  end
  GuiLayoutEnd(gui)

  -- widgets (right)
  GuiText(gui, 0, 0, "  ") -- don't get too close to labels
  GuiLayoutBeginVertical(gui, 0, 0)
  for _, setting in ipairs(custom_always_cast_settings) do
    if not setting.hidden and setting.type == "action" then
      local value = ModSettingGetNextValue(setting.key)
      local text = value and GameTextGet("$option_on") or GameTextGet("$option_off")
      if GuiButton(gui, id(), 0, 0, text) then
        ModSettingSetNextValue(setting.key, not value, false)
      end
      GuiLayoutAddVerticalSpacing(gui, 5)
    end
  end
  GuiLayoutEnd(gui) -- end widgets

  GuiLayoutEnd(gui) -- end main area

  -- prevent overlap
  for _, setting in ipairs(custom_always_cast_settings) do
    if not setting.hidden then
      GuiLayoutAddVerticalSpacing(gui, 5)
      GuiText(gui, 0, 0, " ")
    end
  end
end
