script = "Awareness"
author = "Jiingz"
description = "League8 Original Utilities"

function OnPreUpdate() end
function OnUpdate() end
function OnBuffGain(unit, buff) end
function OnBuffLose(hero, buff) end
function OnDash(unit, dash_pos, dash_speed, dash_start_time) end
function OnProcessSpell(unit, spell) end
function OnRecall(unit) end
function OnTeleport(unit) end
function OnNewPath(waypoint, unit) end
function OnMissile(missile) end

core_ = nil

--Settings
show_wards = true
last_position_tracker = true
jungle_tracker = true
possible_passed_distance = true

show_wards_minimap = true
last_position_tracker_minimap = true
jungle_tracker_minimap = true
fow_exploit = true

fow_recall_tracker = true
anonymous_recall_ping = true

gank_tracker_active = true
gank_tracker_min_distance = 500

function OnLoad(core)
core_ = core

--core_:UpdatePlugin("https://raw.githubusercontent.com/Jiingz/CarryBuddyAssemblies/main/Awareness.lua","Awareness.lua")
end

function OnPreOrbwalker()

end

function OnPostOrbwalker()


end

function LoadCfg(config)
    show_wards = config:GetBool("show_wards", true)
    jungle_tracker = config:GetBool("jungle_tracker", true)
    last_position_tracker = config:GetBool("last_position_tracker", true)
    possible_passed_distance = config:GetBool("possible_passed_distance", true)
    jungle_tracker_minimap = config:GetBool("jungle_tracker_minimap",true)
    fow_exploit = config:GetBool("fow_exploit", true)
    fow_recall_tracker = config:GetBool("fow_recall_tracker",true)
    anonymous_recall_ping = config:GetBool("anonymous_recall_ping", true)

    gank_tracker_active = config:GetBool("gank_tracker_active", true)
    gank_tracker_min_distance = config:GetFloat("gank_tracker_min_distance", 500)

    --show_wards_minimap = config:GetBool("show_wards_minimap", true)
    last_position_tracker_minimap = config:GetBool("last_position_tracker_minimap", true)
    
end


function SaveCfg(config) 
    config:SetBool("show_wards", show_wards)
    config:SetBool("last_position_tracker", last_position_tracker)
    config:SetBool("jungle_tracker", jungle_tracker)
    config:SetBool("possible_passed_distance", possible_passed_distance)
    config:SetBool("fow_exploit", fow_exploit)
    config:SetBool("fow_recall_tracker", fow_recall_tracker)
  --  config:SetBool("anonymous_recall_ping", anonymous_recall_ping)

    config:SetBool("gank_Tracker_active", gank_tracker_active)
    config:SetFloat("gank_tracker_min_distance", gank_tracker_min_distance)

   -- config:SetBool("show_wards_minimap", show_wards_minimap)
    config:SetBool("last_position_tracker_minimap", last_position_tracker_minimap)
    --config:SetBool("jungle_tracker_minimap", jungle_tracker_minimap)
end

function DrawSettings(ui)

   show_wards = ui:Checkbox("Ward Tracker", show_wards)
   ui:Tooltip("Track wards placed by enemies (You must have vision on them when they place it in order to track it!)")

   jungle_tracker = ui:Checkbox("FOW Jungle Tracker", jungle_tracker)
   ui:Tooltip("Track all available junglecamps.")

   last_position_tracker = ui:Checkbox("Last Position Tracker", last_position_tracker)
   ui:Tooltip("Track the last position of the enemy.")

    if(last_position_tracker) then
        last_position_tracker_minimap = ui:Checkbox("Last position on Minimap", last_position_tracker_minimap)
        ui:Tooltip("Draws the champion icon and the last seen time on the minimap.")
        possible_passed_distance = ui:Checkbox("Show possible passed distance", possible_passed_distance)
        ui:Tooltip("Draw a circle to see how far the enemy could have go.")
    end

   fow_exploit = ui:Checkbox("FOW Exploit", fow_exploit)
   ui:Tooltip("Shows the enemy champion model in FOW (Situational, this does not trigger 100%!)")

   fow_recall_tracker = ui:Checkbox("FOW Recalltracker", fow_recall_tracker)
   ui:Tooltip("Shows the enemy champion position when he's recalling in FOW. Unlike the FOW exploit, this works 100% of the time.")

   gank_tracker_active = ui:Checkbox("Gank Tracker", gank_tracker_active)
   ui:Tooltip("Draw line to enemy.")
   if(gank_tracker_active) then
    gank_tracker_min_distance = ui:DragFloat5("GankTracker minimum Distance", gank_tracker_min_distance, 5, 500, 1800)
   end
--   ui:Separator()
--   ui:LabelText("##minimap_config", "Minimap Settings:")
   --show_wards_minimap = ui:Checkbox("Show Wards", show_wards_minimap)
end

function GankTracker()

   for idx, hero in pairs(core_.champs) do
        if(hero.is_alive and hero.is_targetable and hero.is_visible and hero:IsEnemyTo(core_:GetPlayer()) and core_:Distance(hero, core_:GetPlayer()) <= gank_tracker_min_distance) then
            screen_pos1 = core_:WorldToScreen(core_:GetPlayer().pos)
            screen_pos2 = core_:WorldToScreen(hero.pos)
          --  core_:DrawTriangleWorld(core_:GetPlayer().pos, core_:GetPlayer().pos:Add(Vec3(200,0,100)), hero.pos, 2, Color:RED())
            core_:DrawLine(screen_pos1, screen_pos2, 2, Color:WHITE())
            screen_pos1 = Vec2(screen_pos1.x + idx * 10, screen_pos1.y + idx * 10)
            core_:DrawText(screen_pos1, hero.name.." ("..math.floor(screen_pos1:Distance(screen_pos2)).." meters)", Color(255,255,255,255))
        end
    end

end

function TrackJungleCamps()

    if(jungle_tracker ~= true) then
        return
    end

    for idx, item in pairs(core_.jungle) do
       -- screen_pos = core_:WorldToScreen(item.pos)
       -- core_:DrawText(screen_pos, item.name, Color:LOL())
       if(string.find(item.name,"mini") ) then
            
       else
            map_pos = core_:WorldToMinimap(item.pos)
            map_pos_optimized = Vec2(map_pos.x - 5, map_pos.y - 15)
            imageSize = Vec2(map_pos_optimized.x + 15, map_pos_optimized.y + 15)
            core_:DrawImageRounded("jungle",map_pos_optimized,imageSize, 500)
       end
          
    end
end

function IsReady(spell)
    if(spell:GetCurrentCooldown(core_.time) <= 0) then return true else return false end
end

function CooldownTracker()

    for idx, hero in pairs(core_.champs) do

        if(hero.is_alive and hero:IsEnemyTo(core_:GetPlayer()) and hero.is_visible) then 
            local q_ready = IsReady(hero.Q)
            local w_ready = IsReady(hero.W)
             local e_ready = IsReady(hero.E)
             local r_ready = IsReady(hero.R)

             local d_ready = IsReady(hero.D)
             local f_ready = IsReady(hero.F)
              
      
      
             q_pos = Vec2(core_:GetHpBarPos(hero).x - 40, core_:GetHpBarPos(hero).y)
      
              if(q_ready) then
                  core_:DrawText(q_pos,"Q",Color(0,255,0,255))
              else
                  core_:DrawText(q_pos,"Q",Color(255,0,0,255))
              end
      
              w_pos = Vec2(core_:GetHpBarPos(hero).x - 20, core_:GetHpBarPos(hero).y)
              if(w_ready) then
                  core_:DrawText(w_pos,"W",Color(0,255,0,255))
              else
                  core_:DrawText(w_pos,"W",Color(255,0,0,255))
              end
      
              e_pos = Vec2(core_:GetHpBarPos(hero).x, core_:GetHpBarPos(hero).y)
              if(e_ready) then
                  core_:DrawText(e_pos,"E",Color(0,255,0,255))
              else
                  core_:DrawText(e_pos,"E",Color(255,0,0,255))
              end
      
              r_pos = Vec2(core_:GetHpBarPos(hero).x + 20, core_:GetHpBarPos(hero).y)
              if(r_ready) then
                  core_:DrawText(r_pos,"R",Color(0,255,0,255))
              else
                  core_:DrawText(r_pos,"R",Color(255,0,0,255))
              end

              d_pos = Vec2(core_:GetHpBarPos(hero).x - 85, core_:GetHpBarPos(hero).y - 30)
              if(d_ready) then
                core_:DrawText(d_pos,"D",Color(0,255,0,255))
              else
                core_:DrawText(d_pos,"D",Color(255,0,0,255))
               end

               f_pos = Vec2(core_:GetHpBarPos(hero).x - 85, core_:GetHpBarPos(hero).y - 10)
               if(f_ready) then
                 core_:DrawText(f_pos,"F",Color(0,255,0,255))
               else
                 core_:DrawText(f_pos,"F",Color(255,0,0,255))
                end
        end

     

    end

end

function WardTracker()

    if(show_wards) then
        for idx, 
    item in pairs(core_.wards) do
            item:ForceVisible(true)
            if (core_:IsWorldPointOnScreen(item.pos) and item:IsEnemyTo(core_:GetPlayer()) and item:HasUnitTag(UnitTag:Unit_Ward()) and item:HasUnitTag(UnitTag:Unit_Plant()) == false and item.is_alive) then
           
                screen_pos = Vec2(core_:WorldToScreen(item.pos).x - 25, core_:WorldToScreen(item.pos).y - 30)

                text_pos = Vec2(screen_pos.x + 20, screen_pos.y - 15)
   
                --set imageSize again to draw on the screen instead of minimap
                imageSize = Vec2(screen_pos.x + 50, screen_pos.y + 50)

                if(item.name ~= "jammerdevice" and item.name ~= "bluetrinket") then
                    core_:DrawText(text_pos, tostring(math.floor(core_.time - item.last_visible_at)),Color:PURPLE())
                    core_:DrawCircleWorld(item.pos, 50, 90, 1, Color:YELLOW())
                    core_:DrawCircleWorld(item.pos, 100, 90, 1, Color:YELLOW())
                else
                    core_:DrawCircleWorld(item.pos, 50, 90, 1, Color:RED())
                    core_:DrawCircleWorld(item.pos, 100, 90, 1, Color:RED())
                end

             --   core_:DrawCircleWorld(item.pos, 50, 100, 2, Color:YELLOW())
            end
        end
    end

end

function FOWExploit()
    for idx, item in pairs(core_.champs) do

        if(item:IsEnemyTo(core_:GetPlayer())) then
            item:ForceVisible(false)
            if(item.is_visible == false and item.is_moving) then
                item:ForceVisible(false)
            end

            
        end

    end
end


function TrackLastPosition()

    if(last_position_tracker) then
        for idx, 
    item in pairs(core_.champs) do
        
            if (item.is_visible == false and item:IsEnemyTo(core_:GetPlayer()) and item:HasUnitTag(UnitTag:Unit_Champion()) and item.is_alive) then
           
                screen_pos = Vec2(core_:WorldToScreen(item.pos).x - 25, core_:WorldToScreen(item.pos).y - 30)
                minimap_pos = core_:WorldToMinimap(item.pos)
                imageSize = Vec2(screen_pos.x + 50, screen_pos.y + 50)
    
                text_pos = Vec2(screen_pos.x + 20, screen_pos.y - 15)
    
                name_pos = text_pos:Clone()
                name_pos.y = name_pos.y - 15

                possible_unit_path = (core_.time - item.last_visible_at) * item.movement_speed

                if(core_:IsWorldPointOnScreen(item.pos)) then
                    core_:DrawImageRounded(item.name.."_square",screen_pos,imageSize, 20)

                    core_:DrawCircleWorld(item.pos, possible_unit_path, 90, 1, Color(176/255,0,53/255,1))
                    core_:DrawText(text_pos, tostring(math.floor(core_.time - item.last_visible_at)),Color(255,255,255,255))
                    core_:DrawText(name_pos, item.name,Color(255,255,255,255))
                end

                if(last_position_tracker_minimap) then 
                    map_pos = core_:WorldToMinimap(item.pos)
                    imageSize = Vec2(map_pos.x + 25, map_pos.y + 25)
                    core_:DrawImageRounded(item.name.."_square",map_pos,imageSize, 2)
                    core_:DrawText(map_pos, tostring(math.floor(core_.time - item.last_visible_at)),Color(255,255,255,255))
                end
             --   core_:DrawCircleWorld(item.pos, 50, 100, 2, Color:YELLOW())
            end
        end
    end

end

function OnDraw(ui) 
  GankTracker()
  WardTracker()
  TrackLastPosition()
  TrackJungleCamps()
  FOWExploit()
  CooldownTracker()
end	

function OnUpdate()
end

function OnRecall(unit, recall_start_time)

    if(fow_recall_tracker == false or unit:IsEnemyTo(core_:GetPlayer()) == false) then return end

    hp_bar_pos = Vec2(core_:GetHpBarPos(unit).x - 50, core_:GetHpBarPos(unit).y)
    line_end = Vec2(hp_bar_pos.x + 100, hp_bar_pos.y)
    core_:DrawLine(hp_bar_pos,line_end,5, Color(255,255,255,255))

    line_end = Vec2(hp_bar_pos.x + (unit.health/unit.max_health) * 100, hp_bar_pos.y)
    core_:DrawLine(hp_bar_pos,line_end,5, Color(0,255,0,255))

    core_:DrawText(Vec2(hp_bar_pos.x,hp_bar_pos.y -20), math.floor(unit.health).."/"..math.floor(unit.max_health).." ("..math.floor(((unit.health/unit.max_health) * 100)).."%)", Color(0,255,0,255))

    -- recall tracker bar

    minimap_pos = Vec2(core_:GetMinimapPos().x, core_:GetMinimapPos().y - 50 * (unit.herolist_index + 1))

    recall_time = 8
    if(unit.recall_state == 11) then recall_time = 4 end

    core_:DrawLine(minimap_pos,Vec2((minimap_pos.x + core_:GetMinimapSize().x), minimap_pos.y), 13, Color(12/255,22/255,20/255,255))

    core_:DrawText(Vec2(minimap_pos.x,minimap_pos.y - 20),unit.name,Color(255,255,255,255))
    recall_tracker_line_end = Vec2((minimap_pos.x + core_:GetMinimapSize().x + 100) - ((core_.time + recall_time) - recall_start_time) * (22.2 * (8 / recall_time)), minimap_pos.y)
    core_:DrawLine(minimap_pos,recall_tracker_line_end, 8, Color(5/255,104/255,97/255,255))

    core_:DrawCircleWorld(unit.pos, (core_.time - recall_start_time) * 30, 90, 1, Color(23/255,92/255,193/255,255))
    core_:DrawCircleWorld(unit.pos, (core_.time - recall_start_time) * 35, 90, 1, Color(23/255,92/255,193/255,255))
    core_:DrawCircleWorld(unit.pos, (core_.time - recall_start_time) * 40, 90, 1, Color(23/255,92/255,193/255,255))
  --  unit:ForceVisible(true)
    
end