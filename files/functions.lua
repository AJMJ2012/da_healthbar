dofile_once("data/scripts/lib/utilities.lua")

function EntityGetVariableString(entity, variable_tag, default)
	local variable = EntityGetFirstComponent(entity, "VariableStorageComponent", variable_tag);
	if variable ~= nil then
		return ComponentGetValue2(variable, "value_string");
	end
	return default;
end

function EntityGetVariableNumber(entity, variable_tag, default)
	return tonumber(EntityGetVariableString(entity, variable_tag, default));
end

function EntitySetVariableString(entity, variable_tag, value)
	local current_variable = EntityGetFirstComponent(entity, "VariableStorageComponent", variable_tag);
	if current_variable == nil then
		EntityAddComponent(entity, "VariableStorageComponent", {
			_tags=variable_tag..",enabled_in_world,enabled_in_hand,enabled_in_inventory",
			value_string=tostring(value)
		});
	else
		ComponentSetValue2(current_variable, "value_string", value);
	end
end

function EntitySetVariableNumber(entity, variable_tag, value)
	return EntitySetVariableString(entity, variable_tag, value);
end

function EntityGetFirstHitboxSize(entity, fallbackWidth, fallbackHeight)
	local hitbox = EntityGetFirstComponent(entity, "HitboxComponent")
	local width = fallbackWidth or 0
	local height = fallbackHeight or 0
	if hitbox ~= nil then
		width = ComponentGetValue2(hitbox, "aabb_max_x") - ComponentGetValue2(hitbox, "aabb_min_x")
		height = ComponentGetValue2(hitbox, "aabb_max_y") - ComponentGetValue2(hitbox, "aabb_min_y")
	end
	return width, height
end

function EntityEnableHealthBar(entity)
	for _,component in pairs(EntityGetComponent(entity, "SpriteComponent", "health_bar") or {}) do
		EntitySetComponentIsEnabled(entity, component, true)
	end
	for _,component in pairs(EntityGetComponent(entity, "SpriteComponent", "health_bar_back") or {}) do
		EntitySetComponentIsEnabled(entity, component, true)
	end
end

function EntityDisableHealthBar(entity)
	for _,component in pairs(EntityGetComponent(entity, "SpriteComponent", "health_bar") or {}) do
		EntitySetComponentIsEnabled(entity, component, false)
	end
	for _,component in pairs(EntityGetComponent(entity, "SpriteComponent", "health_bar_back") or {}) do
		EntitySetComponentIsEnabled(entity, component, false)
	end
end

function EntitySetPreviousHealth(entity)
	local health = EntityGetHealth(entity)
	local previous_health = EntityGetPreviousHealth(entity)
	local max_health = EntityGetMaxHealth(entity)
	if previous_health == 0 or not ModSettingGet("da_healthbar.lerp") then
		EntitySetVariableNumber(entity, "previous_hp", health)
	elseif previous_health > health then
		EntitySetVariableNumber(entity, "previous_hp", math.min(max_health, math.max(health, previous_health - (max_health / 90))))
	elseif previous_health < health then
		EntitySetVariableNumber(entity, "previous_hp", math.min(health, math.max(0, previous_health + (max_health / 30))))
	end
end

function EntityGetHealth(entity)
	local current_hp = 0
	for _,component in pairs(EntityGetComponent(entity, "DamageModelComponent") or {}) do
		local hp = ComponentGetValue2(component, "hp")
		if hp > current_hp then
			current_hp = hp
		end
	end
	return current_hp
end

function EntityGetMaxHealth(entity)
	local current_max_hp = 0
	for _,component in pairs(EntityGetComponent(entity, "DamageModelComponent") or {}) do
		local max_hp = ComponentGetValue2(component, "max_hp")
		if max_hp > current_max_hp then
			current_max_hp = max_hp
		end
	end
	return current_max_hp
end

function EntityGetPreviousHealth(entity)
	return EntityGetVariableNumber(entity, "previous_hp", 0) or 0
end

function EntityGetHealthRatio(entity)
	local current_hp = EntityGetHealth(entity)
	local current_max_hp = EntityGetMaxHealth(entity)
	local ratio = current_hp / current_max_hp
	if ratio ~= ratio then
		return 0
	end
	return ratio
end

function EntityGetPreviousHealthRatio(entity)
	local previous_hp = EntityGetPreviousHealth(entity)
	local current_max_hp = EntityGetMaxHealth(entity)
	local ratio = previous_hp / current_max_hp
	if ratio ~= ratio then
		return EntityGetHealthRatio(entity)
	end
	return ratio
end