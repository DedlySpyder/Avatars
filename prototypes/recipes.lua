data:extend ({
 {
    type = "recipe",
    name = "avatar",
    enabled = false,
    ingredients =
    {
      {type="item", name="avatar-head", amount=1},
      {type="item", name="avatar-arm", amount=2},
      {type="item", name="avatar-leg", amount=2},
      {type="item", name="avatar-torso", amount=1},
      {type="item", name="avatar-skin", amount=2}
    },
    results = {{type="item", name="avatar", amount=1}},
    category = "advanced-crafting",
    energy_required = 20
 },
 {
    type = "recipe",
    name = "avatar-control-center",
    enabled = false,
    ingredients =
    {
      {type="item", name="steel-plate", amount=100},
      {type="item", name="stone-brick", amount=50},
      {type="item", name="radar", amount=10},
      {type="item", name="fission-reactor-equipment", amount=1},
      {type="item", name="power-armor", amount=1}
    },
    results = {{type="item", name="avatar-control-center", amount=1}},
    category = "advanced-crafting",
    energy_required = 30
 },
 {
    type = "recipe",
    name = "avatar-remote-deployment-unit",
    enabled = false,
    ingredients =
    {
      {type="item", name="steel-plate", amount=20},
      {type="item", name="iron-gear-wheel", amount=20},
      {type="item", name="fast-inserter", amount=5},
      {type="item", name="processing-unit", amount=5},
      {type="item", name="radar", amount=1}
    },
    results = {{type="item", name="avatar-remote-deployment-unit", amount=1}},
    category = "crafting",
    energy_required = 5
 },
 {
    type = "recipe",
    name = "actuator",
    enabled = false,
    ingredients =
    {
      {type="item", name="processing-unit", amount=3},
      {type="item", name="electric-engine-unit", amount=5},
      {type="item", name="steel-plate", amount=5},
      {type="item", name="iron-gear-wheel", amount=3}
    },
    results = {{type="item", name="actuator", amount=1}},
    category = "crafting",
    energy_required = 10
 },
 {
    type = "recipe",
    name = "avatar-arm",
    enabled = false,
    ingredients =
    {
      {type="item", name="actuator", amount=3},
      {type="item", name="low-density-structure", amount=10}
    },
    results = {{type="item", name="avatar-arm", amount=1}},
    category = "advanced-crafting",
    energy_required = 20
 },
 {
    type = "recipe",
    name = "avatar-leg",
    enabled = false,
    ingredients =
    {
      {type="item", name="actuator", amount=3},
      {type="item", name="low-density-structure", amount=12}
    },
    results = {{type="item", name="avatar-leg", amount=1}},
    category = "advanced-crafting",
    energy_required = 20
 },
 {
    type = "recipe",
    name = "avatar-head",
    enabled = false,
    ingredients =
    {
      {type="item", name="actuator", amount=1},
      {type="item", name="low-density-structure", amount=2},
      {type="item", name="processing-unit", amount=50},
      {type="item", name="radar", amount=1}
    },
    results = {{type="item", name="avatar-head", amount=1}},
    category = "advanced-crafting",
    energy_required = 45
 },
 {
    type = "recipe",
    name = "avatar-torso",
    enabled = false,
    ingredients =
    {
      {type="item", name="avatar-internals", amount=1},
      {type="item", name="low-density-structure", amount=20}
    },
    results = {{type="item", name="avatar-torso", amount=1}},
    category = "advanced-crafting",
    energy_required = 30
 },
 {
    type = "recipe",
    name = "avatar-internals",
    enabled = false,
    ingredients =
    {
      {type="item", name="fission-reactor-equipment", amount=2},
      {type="item", name="efficiency-module-3", amount=5},
      {type="item", name="speed-module-3", amount=5},
      {type="item", name="actuator", amount=2},
      {type="item", name="low-density-structure", amount=5}
    },
    results = {{type="item", name="avatar-internals", amount=1}},
    category = "advanced-crafting",
    energy_required = 30
 },
 {
    type = "recipe",
    name = "avatar-skin",
    enabled = false,
    ingredients =
    {
      {type="item", name="plastic-bar", amount=20},
      {type="fluid", name="water", amount=100}
    },
    results = {{type="item", name="avatar-skin", amount=1}},
    category = "advanced-crafting",
    energy_required = 30
 }
})