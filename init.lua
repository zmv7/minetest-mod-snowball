minetest.register_on_mods_loaded(function()
minetest.override_item("default:snow", {
	on_use = function(itemstack, user, pointed_thing)
			if not minetest.check_player_privs(user:get_player_name(), {creative = true}) then itemstack:take_item()
		end
		local pos = user:getpos()
		local dir = user:get_look_dir()
		local yaw = user:get_look_yaw()
		if pos and dir then
			pos.y = pos.y + 1.5
			local obj = minetest.add_entity(pos, "snowball:ball")
			if obj then
				obj:setvelocity({x=dir.x * 20, y=dir.y * 20, z=dir.z * 20})
				obj:setacceleration({x=dir.x * -3, y=-10, z=dir.z * -3})
				obj:setyaw(yaw)
			end
		end
		return itemstack
	end,
})
end)
local SNOWBALL = {
	physical = false,
	timer = 0,
	visual = "sprite",
	visual_size = {x=0.5, y=0.5,},
	textures = {'default_snowball.png'},
	lastpos= {},
	collisionbox = {0, 0, 0, 0, 0, 0},
}
SNOWBALL.on_step = function(self, dtime)
	self.timer = self.timer + dtime
	local pos = self.object:getpos()
	local node = minetest.get_node(pos)

	if self.timer > 0.2 then
		local objs = minetest.get_objects_inside_radius({x = pos.x, y = pos.y, z = pos.z}, 1)
		for k, obj in pairs(objs) do
			if obj:get_luaentity() == nil or obj:get_luaentity().name ~= "snowball:ball" then
				obj:punch(self.object, 1.0, {
					full_punch_interval = 1.0,
					damage_groups= {fleshy = 1},
				}, nil)
				minetest.sound_play("default_dig_cracky", {pos = self.lastpos, gain = 0.8})
				self.object:remove()
			end
		end
	end

	if self.lastpos.x ~= nil then
		if minetest.registered_nodes[node.name].walkable then
			if not minetest.is_protected(self.lastpos,"") then
				minetest.add_node(self.lastpos, {name="default:snow",param2=0})
				minetest.check_for_falling(self.lastpos)
			end
			minetest.sound_play("default_dig_cracky", {pos = self.lastpos, gain = 0.8})
			self.object:remove()
		end
	end
	self.lastpos= {x = pos.x, y = pos.y, z = pos.z}
end

minetest.register_entity("snowball:ball", SNOWBALL)
