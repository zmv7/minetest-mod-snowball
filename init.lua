minetest.register_on_mods_loaded(function()
	minetest.override_item("default:snow", {
		on_use = function(itemstack, user, pointed_thing)
			local name = user:get_player_name()
			if not name then return end
			if not minetest.check_player_privs(name, {creative = true}) then
				itemstack:take_item()
			end
			local pos = user:get_pos()
			local dir = user:get_look_dir()
			local yaw = user:get_look_horizontal()
			local vel = user:get_velocity()
			if pos and dir then
				pos.y = pos.y + 1.5
				local obj = minetest.add_entity(pos, "snowball:snowball", name)
				if obj then
					obj:set_velocity({x=dir.x * 20 + vel.x, y=dir.y * 20 + vel.y, z=dir.z * 20 + vel.z})
					obj:set_acceleration({x=0, y=-9.81, z=0})
					obj:set_yaw(yaw)
				end
			end
			return itemstack
	end})
end)

minetest.register_entity("snowball:snowball",{
	physical = true,
	timer = 0,
	visual = "sprite",
	visual_size = {x=0.5, y=0.5,},
	textures = {'default_snowball.png'},
	collisionbox = {-0.25,-0.25,-0.25,0.25,0.25,0.25},
	pointable = false,
	collide_with_objects = false,
	on_activate = function(self, staticdata)
		self.thrower = staticdata
	end,
	on_step = function(self, dtime, moveresult)
		self.timer = self.timer + dtime
		local pos = self.object:get_pos()
		local vel = self.object:get_velocity()
		if vel then
			self.object:set_velocity({x=0.6^dtime*vel.x,y=vel.y,z=0.6^dtime*vel.z})
		end
		if moveresult.collides then
			if not minetest.is_protected(pos,"") and minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name ~= "default:snow" then
				minetest.add_node(pos, {name="default:snow",param2=0})
				minetest.check_for_falling(pos)
			end
			minetest.sound_play("default_dig_cracky", {pos = self.lastpos, gain = 0.8})
			self.object:remove()
		end
		if self.timer > 0.2 then
			local objs = minetest.get_objects_inside_radius({x = pos.x, y = pos.y-1, z = pos.z}, 1)
			local thrower = type(self.thrower) == "string" and minetest.get_player_by_name(self.thrower) or self.object
			for _, obj in pairs(objs) do
				local prop = obj:get_properties()
				local name = obj:get_luaentity() and obj:get_luaentity().name
				if obj:is_player() or (prop and prop.physical == true and name ~= "snowball:snowball" and name ~= "__builtin:item") then
					obj:punch(thrower, 1.0, {
						full_punch_interval = 1.0,
						damage_groups= {fleshy = 1},
					}, nil)
					minetest.sound_play("default_dig_cracky", {pos = pos, gain = 0.8})
					self.object:remove()
				end
			end
		end
	end
})
