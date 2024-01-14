-- types:
-- bool-setting - a true/false checkbox
-- int-setting - a signed 64 bit integer textfield (or selection dropdown)
-- double-setting - a double precision floating point textfield (or selection dropdown)
-- string-setting - a string textfield (or selection dropdown)
-- color-setting - a color picker (sliders), with whole number textfields. Includes alpha.

-- setting-type:
-- startup: This kind of setting is available in the prototype stage, and can not be changed runtime. They have to be set to the same values for all players on a server.
-- runtime-global: This kind of setting is global to an entire save game and can be changed runtime. On servers, only admins can change these settings.
-- runtime-per-user: This kind of setting is only available runtime in the control.lua stage and each player has their own instance of this setting. 
-- When a player joins a server their local setting of "keep mod settings per save" determines if the local settings they have set 
-- are synced to the loaded save or if the save's settings are used.
data:extend({
    {
        type = "string-setting",
        name = "inserter-hints-direction",
        setting_type = "runtime-per-user",
        default_value = "auto",
        allowed_values = {"auto", "vertical", "horizontal"},
        order = "10"
    }, {
        type = "int-setting",
        name = "inserter-hints-count",
        setting_type = "runtime-per-user",
        default_value = 10,
        minimum_value = 5,
        maximum_value = 20,
        order = "20"
    }, {
        type = "int-setting",
        name = "inserter-hints-offset",
        setting_type = "runtime-per-user",
        default_value = 7,
        minimum_value = 1,
        maximum_value = 20,
        order = "30"
    },
})