data:extend({
  {
    type = "item",
    name = "avatar",
    icon = "__base__/graphics/icons/player.png", --change all of this
    flags = {"goes-to-quickbar"},
    subgroup = "storage",
    order = "a[items]-b[avatar]",
    place_result = "avatar",
    stack_size = 1
  },
  {
	type = "item",
	name = "avatar-control-center",
	icon = "__Avatars__/graphics/avatar-control-center-icon.png", --change all of this
	flags = {"goes-to-quickbar"},
	subgroup = "storage",
	order = "a[items]-c[avatar-control-center]",
	place_result = "avatar-control-center",
	stack_size = 1
  }
})