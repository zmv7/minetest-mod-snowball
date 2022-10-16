core.register_on_mods_loaded(function()
	core.override_item("default:snow", {
		on_use = function(itemstack, user, pointed_thing)
			local name = user:get_player_name()
			if not name then return end
			if not core.check_player_privs(name, {creative = true}) then
				itemstack:take_item()
			end
			local pos = user:get_pos()
			local dir = user:get_look_dir()
			local yaw = user:get_look_horizontal()
			if pos and dir then
				pos.y = pos.y + 1.5
				local obj = core.add_entity(pos, "snowball:snowball", name)
				if obj then
					obj:set_velocity({x=dir.x * 20, y=dir.y * 20, z=dir.z * 20})
					obj:set_acceleration({x=dir.x * -3, y=-10, z=dir.z * -3})
					obj:set_yaw(yaw)
				end
			end
			return itemstack
	end})
end)
local snowball = {
	physical = true,
	timer = 0,
	visual = "sprite",
	visual_size = {x=0.5, y=0.5,},
	textures = {'default_snowball.png'},
	collisionbox = {-0.25,-0.25,-0.25,0.25,0.25,0.25},
	pointable = false,
	collide_with_objects = false,
}

snowball.on_activate = function(self, staticdata)
	local thrower = core.get_player_by_name(staticdata)
	if thrower then
		self["thrower"] = thrower
	end
end

snowball.on_step = function(self, dtime, moveresult)
	self.timer = self.timer + dtime
	local pos = self.object:get_pos()
	local yaw = self.object:get_yaw()

	if self.timer > 0.2 then
		local objs = core.get_objects_inside_radius({x = pos.x, y = pos.y-1, z = pos.z}, 1)
		for k, obj in pairs(objs) do
		if not obj then goto nodes end
		local prop = obj:get_properties()
		local name = obj:get_luaentity() and obj:get_luaentity().name
		if not prop then goto nodes end
			if obj:is_player() or (prop.physical == true and name ~= "snowball:snowball") then
				local thrower = self["thrower"] or self.object
				obj:punch(thrower, 1.0, {
					full_punch_interval = 1.0,
					damage_groups= {fleshy = 1},
				}, nil)
				core.sound_play("default_dig_cracky", {pos = pos, gain = 0.8})
				self.object:remove()
			end
		end
	end
::nodes::
	if moveresult.collides then
		if not core.is_protected(pos,"") then
			core.add_node(pos, {name="default:snow",param2=0})
			core.check_for_falling(pos)
		end
		core.sound_play("default_dig_cracky", {pos = self.lastpos, gain = 0.8})
		self.object:remove()
	end
end

core.register_entity("snowball:snowball", snowball)
