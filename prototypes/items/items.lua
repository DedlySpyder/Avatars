data:extend({
  {
    type = "item",
    name = "avatar",
    icon = "__Avatars__/graphics/icons/avatar.png",
	icon_size = 32,
    flags = {"goes-to-quickbar"},
    subgroup = "avatar",
    order = "a[avatars]-a[avatar]",
    place_result = "avatar",
    stack_size = 1
  },
  {
	type = "item",
	name = "avatar-control-center",
	icon = "__Avatars__/graphics/icons/avatar-control-center.png",
	icon_size = 32,
	flags = {"goes-to-quickbar"},
	subgroup = "avatar-supporting-structures",
	order = "c[control-center]-a[avatar-control-center]",
	place_result = "avatar-control-center",
	stack_size = 5
  },
  {
	type = "item",
	name = "avatar-assembling-machine",
	icon = "__Avatars__/graphics/icons/avatar-assembling-machine.png",
	icon_size = 32,
	flags = {"goes-to-quickbar"},
	subgroup = "avatar-supporting-structures",
	order = "a[assembly]-a[avatar-assembling-machine]",
	place_result = "avatar-assembling-machine",
	stack_size = 5
  },
  {
	type = "item",
	name = "avatar-remote-deployment-unit",
	icon = "__Avatars__/graphics/icons/avatar-remote-deployment-unit.png",
	icon_size = 32,
	flags = {"goes-to-quickbar"},
	subgroup = "avatar-supporting-structures",
	order = "b[remote-structures]-a[avatar-remote-deployment-unit]",
	place_result = "avatar-remote-deployment-unit",
	stack_size = 5
  }
})
