function OnPlayerSpawned(player_entity)
	if EntityGetFirstComponent(player_entity, "LuaComponent", "da_healthbar_player_update") == nil then
		EntityAddComponent(player_entity, "LuaComponent", {
			_tags="da_healthbar_player_update",
			script_source_file="mods/da_healthbar/files/healthbar.lua",
			execute_every_n_frame="1",
		});
	end
end