dofile("data/scripts/lib/mod_settings.lua")

local mod_id = "da_healthbar"
mod_settings_version = 1
mod_settings = {
	{
		id = "enabled_player",
		ui_name = "Enabled for Player",
		value_default = true,
		scope = MOD_SETTING_SCOPE_RUNTIME,
	},
	{
		id = "enabled_npc",
		ui_name = "Enabled for NPCs",
		value_default = true,
		scope = MOD_SETTING_SCOPE_RUNTIME,
	},
	{
		id = "lerp",
		ui_name = "Interpolate Adjustments",
		value_default = true,
		scope = MOD_SETTING_SCOPE_RUNTIME,
	},
	{
		id = "coloured",
		ui_name = "Multicoloured Bars",
		value_default = true,
		scope = MOD_SETTING_SCOPE_RUNTIME,
	}
}


function ModSettingsUpdate(init_scope)
	local old_version = mod_settings_get_version(mod_id)
	mod_settings_update(mod_id, mod_settings, init_scope)
end

function ModSettingsGuiCount()
	return mod_settings_gui_count(mod_id, mod_settings)
end

function ModSettingsGui(gui, in_main_menu)
	mod_settings_gui(mod_id, mod_settings, gui, in_main_menu)
end
