require "nvc\\prediction"

core_ = nil

author = "Jiingz"
script = "Xerath"
targetChampion = "Xerath, Zed, Leona"

QCharged = false
chargedTime = 0
chargedrange = 735
minrange = 735

qCosts = {80,90,100,110,120}
wCosts = {70,80,90,100,110}

Q = {Slot = nil, Range = 735, Delay = 0.6, Radius= 80, Speed = math.huge}
W = {Slot = nil, Range = 900, Delay = 0.5, Radius = 80, Speed = math.huge, Circular = true }
E = {Slot = nil, Range = 735, Delay = 0.25, Width = 140, Speed = 99999}
R = {Slot = nil, Range = 5000, Delay = 0.7, Radius = 80, Speed = math.huge, Circular = true}

use_q = true
use_w = true
use_r = true

function OnLoad(core)
    core_ = core

    Q.Slot = core_:GetPlayer().Q
    W.Slot = core_:GetPlayer().W 
    E.Slot = core_:GetPlayer().E
    R.Slot = core_:GetPlayer().R
end

-- LOGIC

function OnBuffLose(hero, buff) end
function OnDash(unit, dash_pos, dash_speed, dash_start_time) end
function OnProcessSpell(unit, spell) end

local function ComboW()

    if(use_w == false) then return end

    if(core_:GetPlayer():HasBuffString("xerathqlaunchsound") or W.Slot:GetCurrentCooldown(core_.time) > 0 or W.Slot.level == 0 or core_:GetPlayer().mana < wCosts[W.Slot.level]) then return end

    wtarget = core_:GetBestTarget(UnitTag:Unit_Champion(), 1000) 

    if(wtarget == nil) then return end

    pos,castpos,hitchance = GetBestCastPosition(core_, wtarget, W)

    if(hitchance >= 2) then
        core_:CastSpellPos("W", castpos)
    end

    

end

local function ComboR()

    if(use_r == false) then return end

if(R.Slot:GetCurrentCooldown(core_.time) > 0 or R.Slot.level == 0 or core_:GetPlayer().mana < 100) then return end

    rtarget = core_:GetBestTarget(UnitTag:Unit_Champion(), 5000) 

    if(rtarget == nil) then return end

    pos,castpos,hitchance = GetBestCastPosition(core_, rtarget, R)

    --print(hitchance)
   
    if(hitchance >= 2) then

        core_:DrawCircleWorld(pos, 100, 100, 3, Color(255,0,0,255))

        print("x:"..pos.x.."y:"..pos.y.."z:"..pos.z)
        core_:CastSpellPos("R", castpos)
    end

    

end

local function ComboQ()

    if(Q.Slot:GetCurrentCooldown(core_.time) > 0 or Q.Slot.level == 0 or core_:GetPlayer().mana < qCosts[Q.Slot.level]) then 
        QCharged = false
        chargedrange = minrange
      return
    end

    if(use_q == false) then return end

    potential_target = core_:GetBestTarget(UnitTag:Unit_Champion(), 1450) 

    if not QCharged and potential_target ~= nil then
      -- chargedrange = 750
        core_:SetupChargeableSpell("Q")
    end

    
    if(not QCharged and core_:IsKeyDown(16)) then
        -- print("ADAWDWAD")
        -- core_:ResetChargeableSpell("Q") 
     end

  --  print(core_:GetPlayer().casting_spell.name)

    
    if QCharged then
        chargedrange = math.floor((math.min(minrange + (1450 - minrange) * (( core_:GetTickCount() - chargedTime) / 1450) - 100, 1450)))
    end
    

        qtarget = core_:GetBestTarget(UnitTag:Unit_Champion(),chargedrange) 

        if(qtarget ~= nil) then 

         --  pred = GetLinePred(core_, qtarget, core_:GetPlayer().bounding_radius + chargedrange , Q.Speed, Q.Delay)
            Q.Range = chargedrange - 100
            pos,castpos,hitchance = GetBestCastPosition(core_, qtarget, Q)
            
           -- print("x:"..pred.x.."y:"..pred.y.."z:"..pred.z)
            print(hitchance)
            print(chargedrange)

            
            if(hitchance >= 2) then    
                --  print("ADAWDAWDWADADW")
                core_:UpdateChargeableSpell("Q", castpos)
              --  core_:ResetChargeableSpell("Q")
            end

           --  core_:DrawCircleWorld(pred, 100, 100, 3, Color(255,0,0,255))
            
        

        end

end

--Triggered right before OnUpdate
function OnPreUpdate() 


end 
function OnPostOrbwalker() print("POST")  end      
function OnPreOrbwalker() print("PRE") end

--Triggered right before OnUpdate.Main Logic should be called here!
function OnUpdate() 

    if(core_:IsKeyDown(45)) then
        ComboR()
    end

    if(core_.active_mode == core_.mode_combo) then
        ComboW()
        ComboQ()
    end
    

       
end

--Triggered after OnUpdate. All visuals of your Plugin should be handled here.
function OnDraw(ui)
    --core_:DrawCircleWorld(core_:GetPlayer().server_pos, 50, 100, 3, Color(0,255,255,255))
    if(QCharged) then
        core_:DrawCircleWorld(core_:GetPlayer().pos, core_:GetPlayer().bounding_radius + chargedrange, 100, 3, Color(0,0,255,255))
    end
end
--Triggered once a Unit recieves a buff.
function OnBuffGain(unit, buff) 

--print(buff.name)
    if(unit.net_id == core_:GetPlayer().net_id) then
            
        if(buff.name == "xerathqlaunchsound") then

            QCharged = true
           -- print("CHARGING")
            chargedTime = core_:GetTickCount()
            chargedrange = minrange
        end
    end

end

function OnBuffLose(hero, buff)
    print(buff.name)
   if(buff.name == "xerathqvfx") then
    print("RWERFAWDAWDAW")
    QCharged = false
    chargedrange = minrange
    core_:ResetChargeableSpell(0)
    end
end

--Triggered once a Unit recalls.
function OnRecall(unit,time,status)

    print(status)

end

--Triggered once a Unit teleports. Including special cases like Shen R.
function OnTeleport(unit) end

--Triggered once a Unit sets a new Path/does a new movement command.
function OnNewPath(waypoint, unit) end

--Triggered once a Missile has been created (not all Spells are Missiles!!)
function OnMissile(missile) end

--Put all Settings in here
function DrawSettings(ui) 
    if(ui:CollapsingHeader("Combo")) then
        use_q = ui:Checkbox("Use Q", use_q)
        use_w = ui:Checkbox("Use W", use_w)
        use_r = ui:Checkbox("Use R", use_r)
    end
    
end

--Config loading should be handled here.
function LoadCfg(config) 
    use_q = config:GetBool("use_q", true)
    use_w = config:GetBool("use_w", true)
    use_r = config:GetBool("use_r", true)
end

--Config saving should be handled here.
function SaveCfg(config)
    config:SetBool("use_q", use_q)
    config:SetBool("use_w", use_w)
    config:SetBool("use_r", use_r)
end