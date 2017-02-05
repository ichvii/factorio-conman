function copyBlueprint(inStack,outStack)
  if not inStack.is_blueprint_setup() then return end
  outStack.set_blueprint_entities(inStack.get_blueprint_entities())
  outStack.set_blueprint_tiles(inStack.get_blueprint_tiles())
  outStack.blueprint_icons = inStack.blueprint_icons
  if inStack.label then outStack.label = inStack.label end
end

local function onTick()
  if global.managers then
    for _,manager in pairs(global.managers) do
      if not (manager.ent.valid and manager.cc1.valid and manager.cc2.valid) then
        -- if anything is invalid, tear it down (print a message?)

      else
        -- read cc1 signals. Only uses one wire, red if both connected.
        local signet1 = manager.cc1.get_circuit_network(defines.wire_type.red) or manager.cc1.get_circuit_network(defines.wire_type.green)
        local signet2 = manager.cc1.get_circuit_network(defines.wire_type.red) or manager.cc1.get_circuit_network(defines.wire_type.green)
        if signet1 then
          if signet1.get_signal({name="construction-robot",type="item"}) == 1 then
          -- check for conbot=1, build a thing
            local item
            local position = {}
            local direction
            for _,signal in pairs(signet1.signals) do
              -- read item signal, XYD, R, cc2 if relevant
            end


          elseif signet1.get_signal({name="red-wire",type="item"}) == 1 then
          elseif signet1.get_signal({name="green-wire",type="item"}) == 1 then
          elseif signet1.get_signal({name="copper-cable",type="item"}) == 1 then
          -- check r/g/c wire=1, connect a thing

          elseif signet1.get_signal({name="blueprint",type="item"}) == -1 then
            -- transfer blueprint to output
            local inInv = manager.ent.get_inventory(defines.inventory.assembling_machine_input)
            local outInv = manager.ent.get_inventory(defines.inventory.assembling_machine_output)
            outInv[1].set_stack(inInv[1])
            inInv[1].clear()


          elseif signet1.get_signal({name="blueprint",type="item"}) == 1 then
            -- deploy blueprint at XY
            local inInv = manager.ent.get_inventory(defines.inventory.assembling_machine_input)
            --TODO: confirm it's a blueprint and is setup and such...
            local bp = inInv[1]

            --TODO: confirm x&y both set, ignore if not
            local x = signet1.get_signal({name="signal-X",type="virtual"})
            local y = signet1.get_signal({name="signal-Y",type="virtual"})

            local force_build = signet1.get_signal({name="signal-F",type="virtual"})==1

            bp.build_blueprint{
              surface=manager.ent.surface,
              force=manager.ent.force,
              position={x=x,y=y},
              force_build= force_build
            }

          elseif signet1.get_signal({name="blueprint",type="item"}) == 2 then
            -- capture blueprint from XYWH
            local x = signet1.get_signal({name="signal-X",type="virtual"})
            local y = signet1.get_signal({name="signal-Y",type="virtual"})
            local w = signet1.get_signal({name="signal-W",type="virtual"})
            local h = signet1.get_signal({name="signal-H",type="virtual"})

            -- if remote.signalstrings, capture name from cc2


            local inInv = manager.ent.get_inventory(defines.inventory.assembling_machine_input)
            --TODO: confirm it's a blueprint and is setup and such...
            local bp = inInv[1]

            bp.create_blueprint{
              surface = manager.ent.surface,
              force = manager.ent.force,
              area = {{x,y},{x+w,y+h}},
              always_include_times = signet1.get_signal({name="signal-H",type="virtual"})==1,
            }

          elseif signet1.get_signal({name="deconstruction-planner",type="item"}) == 1 then
            -- redprint=1, decon orders
            if not signet2 or #signet2.signals==0 then
              -- decon all
              local x = signet1.get_signal({name="signal-X",type="virtual"})
              local y = signet1.get_signal({name="signal-Y",type="virtual"})
              local w = signet1.get_signal({name="signal-W",type="virtual"})
              local h = signet1.get_signal({name="signal-H",type="virtual"})

              local decon = manager.ent.surface.find_entities({{x,y},{x+w,y+h}})
              for _,e in pairs(decon) do
                e.order_deconstruction(manager.ent.force)
              end
            else
              -- TODO: filtered decon

            end
          end
        end
      end
    end
  end
end

local function onBuilt(event)
  local ent = event.created_entity
  if ent.name == "conman" then

    ent.recipe = "conman-process"
    ent.active = false
    ent.operable = false

    --TODO: find&revive ghosts like dynamic assemblers do
    local cc1 = ent.surface.create_entity{
      name='conman-control',
      position={x=ent.position.x-1,y=ent.position.y+1},
      force=ent.force
    }
    cc1.operable=false
    cc1.minable=false
    cc1.destructible=false

    local cc2 = ent.surface.create_entity{
      name='conman-control',
      position={x=ent.position.x+1,y=ent.position.y+1},
      force=ent.force
    }
    cc2.operable=false
    cc2.minable=false
    cc2.destructible=false

    if not global.managers then global.managers = {} end
    global.managers[ent.unit_number]={ent=ent, cc1 = cc1, cc2 = cc2}

  end
end

local function onPaste(event)
  local ent = event.destination
  if ent.name == "conman" then

  end
end

script.on_event(defines.events.on_tick, onTick)
script.on_event(defines.events.on_built_entity, onBuilt)
script.on_event(defines.events.on_robot_built_entity, onBuilt)
script.on_event(defines.events.on_entity_settings_pasted,onPaste)

remote.add_interface('conman',{
})
