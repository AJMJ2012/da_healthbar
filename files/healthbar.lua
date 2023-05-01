dofile_once("mods/da_healthbar/files/functions.lua")

local healthbar_images = 11

function AddOrReplaceHealthbarComponent(entity, tag, image, xoffset, yoffset, zindex)
	for _,component in pairs(EntityGetComponent(entity, "SpriteComponent", tag) or {}) do
		EntityRemoveComponent(entity, component)
	end
	AddHealthbarComponent(entity, tag, image, xoffset, yoffset, zindex)
end

function AddHealthbarComponent(entity, tag, image, xoffset, yoffset, zindex)
	if EntityGetComponent(entity, "SpriteComponent", tag) == nil then
		EntityAddComponent(entity, "SpriteComponent", { 
			_tags=tag..",ui,no_hitbox",
			has_special_scale="1",
			image_file=image,
			never_ragdollify_on_death="1",
			offset_x=xoffset,
			offset_y=yoffset,
			smooth_filtering="0",
			update_transform="1",
			update_transform_rotation="0",
			z_index=zindex,
		})
	end
end

function RemoveHealthBar(entity)
	for _,component in pairs(EntityGetComponent(entity, "HealthBarComponent") or {}) do
		EntityRemoveComponent(entity, component)
	end
	for i=1,healthbar_images do
		for _,component in pairs(EntityGetComponentIncludingDisabled(entity, "SpriteComponent", "health_bar_foreground_"..i) or {}) do
			EntityRemoveComponent(entity, component)
		end
	end
	for _,component in pairs(EntityGetComponentIncludingDisabled(entity, "SpriteComponent", "health_bar_foreground_alt") or {}) do
		EntityRemoveComponent(entity, component)
	end
	for _,component in pairs(EntityGetComponentIncludingDisabled(entity, "SpriteComponent", "health_bar_midground") or {}) do
		EntityRemoveComponent(entity, component)
	end
	for _,component in pairs(EntityGetComponentIncludingDisabled(entity, "SpriteComponent", "health_bar_midground_alt") or {}) do
		EntityRemoveComponent(entity, component)
	end
	for _,component in pairs(EntityGetComponentIncludingDisabled(entity, "SpriteComponent", "health_bar_background") or {}) do
		EntityRemoveComponent(entity, component)
	end
end

function GetHealthBarSize(entity)
	if EntityHasTag(entity, "boss") and not EntityHasTag(entity, "miniboss") then
		return "huge"
	elseif ((EntityHasTag(entity, "miniboss") or EntityHasTag(entity, "boss_tag")) and (EntityHasTag(entity, "music_energy_100") or EntityHasTag(entity, "music_energy_100_near"))) or (EntityHasTag(entity, "miniboss") and EntityHasTag(entity, "boss_tag")) then
		return "large"
	elseif EntityHasTag(entity, "miniboss") or EntityHasTag(entity, "boss_tag") then
		return "medium"
	else
		return "small"
	end
end

function AddHealthBar(entity)
	local w,h = EntityGetFirstHitboxSize(entity)
	local xoffset = 0
	local yoffset = -h / 2
	local size = GetHealthBarSize(entity)
	if size == "huge" then
		xoffset = 24
	elseif size == "large" then
		xoffset = 18
	elseif size == "medium" then
		xoffset = 12
	else
		xoffset = 6
	end

	EntityAddComponent(entity, "HealthBarComponent")
	for i=1,healthbar_images do
		AddHealthbarComponent(entity, "health_bar_foreground_"..i, "mods/da_healthbar/files/health_bars/"..size.."/health_bar"..i..".png", xoffset, yoffset, -9002)
	end
	AddHealthbarComponent(entity, "health_bar_foreground_alt", "mods/da_healthbar/files/health_bars/"..size.."/health_bar1.png", xoffset, yoffset, -9002)
	AddHealthbarComponent(entity, "health_bar_midground", "mods/da_healthbar/files/health_bars/"..size.."/health_bar_midground.png", xoffset, yoffset, -9001)
	AddHealthbarComponent(entity, "health_bar_midground_alt", "mods/da_healthbar/files/health_bars/"..size.."/health_bar10.png", xoffset, yoffset, -9001)
	AddHealthbarComponent(entity, "health_bar_background", "mods/da_healthbar/files/health_bars/"..size.."/health_bar_background.png", xoffset, yoffset, -9000)
end

function UpdateHealthBar(entity)
	local health_ratio = EntityGetHealthRatio(entity)
	local previous_health_ratio = EntityGetPreviousHealthRatio(entity)
	if health_ratio < 1 or previous_health_ratio < 1 then
		local size = GetHealthBarSize(entity)
		if EntityGetFirstComponent(entity, "HealthBarComponent") == nil then
			AddHealthBar(entity)
		end

		local foreground_scale = health_ratio
		local midground_scale = health_ratio
		if ModSettingGet("da_healthbar.lerp") then
			if previous_health_ratio < health_ratio then
				foreground_scale = previous_health_ratio
				midground_scale = health_ratio
			else
				foreground_scale = health_ratio
				midground_scale = previous_health_ratio
			end
		end

		for i=1,healthbar_images do
			for _,component in pairs(EntityGetComponentIncludingDisabled(entity, "SpriteComponent", "health_bar_foreground_"..i) or {}) do
				ComponentSetValue2(component, "special_scale_x", foreground_scale)
				local health_bar_index = healthbar_images - math.ceil(health_ratio * (healthbar_images - 1))
				EntitySetComponentIsEnabled(entity, component, i == health_bar_index and ModSettingGet("da_healthbar.coloured"))
			end
		end

		for _,component in pairs(EntityGetComponentIncludingDisabled(entity, "SpriteComponent", "health_bar_foreground_alt") or {}) do
			ComponentSetValue2(component, "special_scale_x", foreground_scale)
			EntitySetComponentIsEnabled(entity, component, not ModSettingGet("da_healthbar.coloured"))
		end

		for _,component in pairs(EntityGetComponentIncludingDisabled(entity, "SpriteComponent", "health_bar_midground") or {}) do
			ComponentSetValue2(component, "special_scale_x", midground_scale)
			EntitySetComponentIsEnabled(entity, component, ModSettingGet("da_healthbar.coloured"))
		end
		for _,component in pairs(EntityGetComponentIncludingDisabled(entity, "SpriteComponent", "health_bar_midground_alt") or {}) do
			ComponentSetValue2(component, "special_scale_x", midground_scale)
			EntitySetComponentIsEnabled(entity, component, not ModSettingGet("da_healthbar.coloured"))
		end

	elseif EntityGetComponent(entity, "HealthBarComponent") ~= null then
		RemoveHealthBar(entity)
	end
end

--if (ModSettingGet("da_healthbar.enabled_player") or ModSettingGet("da_healthbar.enabled_npc")) then
	local player_entity = GetUpdatedEntityID()
	local x, y = EntityGetTransform(player_entity)
	local entities = EntityGetInRadiusWithTag(x, y, 512, "mortal")
	for _,entity in pairs(entities) do
		if entity == player_entity or EntityHasTag(entity, "prey") or EntityHasTag(entity, "enemy") then
			EntitySetPreviousHealth(entity)
			if ((entity == player_entity and ModSettingGet("da_healthbar.enabled_player")) or (entity ~= player_entity and ModSettingGet("da_healthbar.enabled_npc"))) and EntityGetHealth(entity) > 0 then
				EntityDisableHealthBar(entity)
				if (entity == player_entity and EntityGetHealthRatio(entity) < EntityGetPreviousHealthRatio(entity)) then
					RemoveHealthBar(entity)
				end
				UpdateHealthBar(entity)
			else
				EntityEnableHealthBar(entity)
				RemoveHealthBar(entity)
			end
		end
	end
--end