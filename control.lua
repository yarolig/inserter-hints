--control.lua

local MOD_PREFIX = 'filter-hints-'
local PICKUP_ACTION = MOD_PREFIX..'pickup-ghost'
local LOADER_TYPES={['loader-1x1']=true, ['loader']=true}

local function p(x)
  game.print(x)
end
local function pp(x)
  game.print(serpent.line(x))
end

local function ppb(x)
  game.print(serpent.block(x))
end

local function initGlobal()
  if not global.players then
    global.players = {}
  end
end

local function initGlobalForPlayerN(n)
  if not global.players then 
    global.players = {}
  end
  if not global.players[n] then 
    global.players[n] = {}
  end
end

local function getPlayer(event)
    return game.get_player(event.player_index)
end

local function gg(event)
    return global.players[event.player_index]
end

script.on_init(function ()
  global.players = {}
end)


script.on_event(defines.events.on_gui_click,
  function (event)
    local player = game.get_player(event.player_index)
    if not player then return end

    if event.element.tags.action == PICKUP_ACTION then
        local item = event.element.tags.hint
        if not player.is_cursor_empty() then
          player.clear_cursor()
        end
        if player.is_cursor_empty() then
          player.cursor_ghost = item
        end
      end
  end
)
local function IsItem(entity_name)
  return game.item_prototypes[entity_name] ~= nil
end

local function IsEquipment(entity_name)
  return game.equipment_prototypes[entity_name] ~= nil
end

local function IsEntity(entity_name)
  return game.entity_prototypes[entity_name] ~= nil
end

local function translateItem(item_name)
  return {
    '?',
    {'equipment-name.'..item_name},
    {'entity-name.'..item_name},
    {'item-name.'..item_name},
    item_name
  }
end

-- TODO: move somewhere to run once
local function IsCraftingMachine(entity_name)
  local craftingMachines = game.get_filtered_entity_prototypes({{filter="crafting-machine", mode="and"}})
  return craftingMachines[entity_name] ~= nil
end

-- TODO: add hints for belts/containers
local function hintsForInserter(entity)
  local e = entity
  if not e then return end
  if e.type ~= 'inserter' then return end
  local tgt = e.pickup_target
  if not tgt then return end
  if not IsCraftingMachine(tgt.name) then return end
  local recipe = tgt:get_recipe()
  if not recipe then return end
  local result = {}
  for _,v in pairs(recipe.products) do
    if v.type == 'item' then
      table.insert(result, v.name)
    end
  end
  return result
end

local function hintsForKrLoader(entity)
  local e = entity
  if not e then return end
  if not LOADER_TYPES[e.type] then return end
  local tgt = e.loader_container
  if not tgt then return end
  if not IsCraftingMachine(tgt.name) then return end
  local recipe = tgt:get_recipe()
  if not recipe then return end
  local result = {}
  for _,v in pairs(recipe.products) do
    if v.type == 'item' then
      table.insert(result, v.name)
    end
  end
  return result
end

local function closeHintsGui(event)
  initGlobalForPlayerN(event.player_index)
  if gg(event).hintsGui then
    gg(event).hintsGui.destroy()
  end
  if global.hintsGui then
    global.hintsGui.destroy()
  end
end

local function openHintsGui(event, hints)
  local player = game.get_player(event.player_index)
  if not player then game.print("no player"); return end
  initGlobalForPlayerN(event.player_index)

  local anchor = {gui=defines.relative_gui_type.inserter_gui,
                  position=defines.relative_gui_position.right}
  gg(event).hintsGui = player.gui.relative.add(
    {type="flow", 
    name=MOD_PREFIX.."inserterHintFlow",
    anchor=anchor,
    direction="vertical"})

  for a=1,8 do
    gg(event).hintsGui.add{type="label", name=MOD_PREFIX.."placeholder"..a, caption=""}  
  end
  local frame = gg(event).hintsGui.add{type="frame", name=MOD_PREFIX.."frame", direction="vertical"}
  frame.add{type="label", name=MOD_PREFIX.."hints-label", caption="Hints:"}
  for k,v in pairs(hints) do
    frame.add{name=MOD_PREFIX.."hint-button" .. k,
              type="sprite-button",
              tags={action=PICKUP_ACTION, hint=v},
              tooltip=translateItem(v),
              sprite='item/' .. v}
  end
end

local function openKrLoaderHintsGui(event, hints)
  local player = game.get_player(event.player_index)
  if not player then game.print("no player"); return end
  initGlobalForPlayerN(event.player_index)

  if not defines.relative_gui_type.loader_gui then return end
  local anchor = {gui=defines.relative_gui_type.loader_gui,
                  position=defines.relative_gui_position.right}
  gg(event).hintsGui = player.gui.relative.add(
    {type="flow", 
    name=MOD_PREFIX.."inserterHintFlow",
    anchor=anchor,
    direction="vertical"})

  for a=1,8 do
    gg(event).hintsGui.add{type="label", name=MOD_PREFIX.."placeholder"..a, caption=""}  
  end
  local frame = gg(event).hintsGui.add{type="frame", name=MOD_PREFIX.."frame", direction="vertical"}
  frame.add{type="label", name=MOD_PREFIX.."hints-label", caption="Hints:"}
  for k,v in pairs(hints) do
    frame.add{name=MOD_PREFIX.."hint-button" .. k,
              type="sprite-button",
              tags={action=PICKUP_ACTION, hint=v},
              tooltip=translateItem(v),
              sprite='item/' .. v}
  end
end



script.on_event(defines.events.on_gui_opened,
  function(event)
    if event.gui_type ~= defines.gui_type.entity then return end
    local isloader = LOADER_TYPES[event.entity.type]
    if event.entity.type ~= 'inserter' and not isloader then return end

    local hints = hintsForInserter(event.entity)
    if hints then
      closeHintsGui(event)
      openHintsGui(event, hints)
      return
    end
    hints = hintsForKrLoader(event.entity)
    if hints then
      closeHintsGui(event)
      openKrLoaderHintsGui(event, hints)
      return
    end

  end
)

script.on_event(defines.events.on_gui_closed,
  function(event)
    closeHintsGui(event)
  end
)
