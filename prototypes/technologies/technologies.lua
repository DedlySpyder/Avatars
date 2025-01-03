data:extend ({

{
    type = "technology",
    name = "avatars",
    icon = "__Avatars__/graphics/technology/avatars.png",
	icon_size = 256,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "avatar"
      },
	  {
        type = "unlock-recipe",
        recipe = "avatar-control-center"
      },
	  {
		type = "unlock-recipe",
		recipe = "avatar-remote-deployment-unit"
	  },
	  {
        type = "unlock-recipe",
        recipe = "actuator"
      },
	  {
        type = "unlock-recipe",
        recipe = "avatar-arm"
      },
	  {
        type = "unlock-recipe",
        recipe = "avatar-leg"
      },
	  {
        type = "unlock-recipe",
        recipe = "avatar-head"
      },
	  {
        type = "unlock-recipe",
        recipe = "avatar-internals"
      },
	  {
        type = "unlock-recipe",
        recipe = "avatar-torso"
      },
	  {
        type = "unlock-recipe",
        recipe = "avatar-skin"
      }
    },
    prerequisites = {"fission-reactor-equipment"},
    unit =
    {
      count = 200,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1},
		{"chemical-science-pack", 1},
		{"utility-science-pack", 1}
      },
      time = 30
    },
    order = "g-c-c",
 }
 })