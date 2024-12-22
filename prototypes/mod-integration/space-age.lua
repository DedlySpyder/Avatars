-- Space Exploration
if mods["space-age"] then
    data.raw["technology"]["avatars"].unit.count = 2000
    Util.Tech.addPrerequisite("avatars", "carbon-fiber")
    Util.Tech.addIngredient("avatars", "space-science-pack")
    Util.Tech.addIngredient("avatars", "agricultural-science-pack")

    Util.Recipe.replaceIngredient("avatar-skin", "plastic-bar", {type="item", name="carbon-fiber", amount=10})
    Util.Recipe.replaceIngredientName("avatar-internals", "efficiency-module-3", "efficiency-module-2")
    Util.Recipe.replaceIngredientName("avatar-internals", "speed-module-3", "speed-module-2")

    Util.Recipe.setCategory("avatar-skin", "organic-or-assembling")

    -- Craftable by Assembling Machines and Electromagnetic Plant
    Util.Recipe.setCategory("avatar", "electronics-with-fluid")
    Util.Recipe.setCategory("actuator", "electronics-with-fluid")
    Util.Recipe.setCategory("avatar-arm", "electronics-with-fluid")
    Util.Recipe.setCategory("avatar-leg", "electronics-with-fluid")
    Util.Recipe.setCategory("avatar-head", "electronics-with-fluid")
    Util.Recipe.setCategory("avatar-torso", "electronics-with-fluid")
    Util.Recipe.setCategory("avatar-internals", "electronics-with-fluid")
end
