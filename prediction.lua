author = "Jiingz"
script = "Prediction"

use_safe_mode = true

function OnLoad(core)
    print("Prediction Loaded")
end

function GetLinePred(core, target, range , missile_speed, cast_time)
   -- print(new_waypoint_list[target.name])

   range = range - 70
   nav = target.nav_end

    ::retry::

     t = target.server_pos:Sub(core:GetPlayer().server_pos):Length() / missile_speed
	t =  t + cast_time 
	veloc =  target.velocity
	veloc.y = 0;
	orientation = veloc:Normalize()
											 
 --   if(target.is_dashing) then 
  --      return Vec3(target.dash_pos.x / target.current_dash_speed, target.dash_pos.y / target.current_dash_speed, target.dash_pos.z / target.current_dash_speed)
  --  end

    core:DrawCircleWorld(orientation, 300, 100, 3, Color(255,255,255,255))

  --  print("PREDICTING")
    result1 = Vec3(orientation.x * target.movement_speed, orientation.y * target.movement_speed, orientation.z * target.movement_speed)
    result2 = Vec3((result1.x * t), (result1.y * t), (result1.z * t) )
	result = target.server_pos:Add(result2)
	
    
    predict2d = core:WorldToScreen(result)
    local2d = core:WorldToScreen(target.server_pos)

	--//ENGINE_MSG("result %f %f %f : time : %f\n", orientation.x, orientation.y, orientation.z,t);
    hitbox = target.bounding_radius

    --result.y = core:GetMap():GetHeightAt(result.x, result.z)    

  -- if(use_safe_mode and result:Distance(target.pos) < hitbox) then
 --   return Vec3(0,0,0)
 --  end

  -- check if result is inside hitbox of target 
  
    return result
--	return Vec3(result.x + hitbox, result.y + hitbox, result.z+hitbox);

end

function GetCirclePrediction(core, target, range, cast_time, radius)

    
    ::retry::

   veloc =  target.velocity
   veloc.y = 0;
   orientation = veloc:Normalize()

   core:DrawCircleWorld(orientation, 300, 100, 3, Color(255,255,255,255))

 --  print("PREDICTING")
   result1 = Vec3(orientation.x * target.movement_speed, orientation.y * target.movement_speed, orientation.z * target.movement_speed)
   result2 = Vec3((result1.x * cast_time), (result1.y * cast_time), (result1.z * cast_time) )
   result = target.server_pos:Add(result2)
   
   
   predict2d = core:WorldToScreen(result)
   local2d = core:WorldToScreen(target.server_pos)

   --//ENGINE_MSG("result %f %f %f : time : %f\n", orientation.x, orientation.y, orientation.z,t);
  

   --result.y = core:GetMap():GetHeightAt(result.x, result.z)

--  if(use_safe_mode and result:Distance(target.server_pos) < hitbox) then
 --  return Vec3(0,0,0)
 -- end

  return result
 -- check if result is inside hitbox of target
--   return result
end

function CheckCollision(core, vec, radius)

    for idx, 
    minion in pairs(core.minions) do

        if(minion.is_alive and minion.is_targetable and minion:IsEnemyTo(core:GetPlayer())) then

            pt1 = core:WorldToScreen(core:GetPlayer().pos)
            pt2 = core:WorldToScreen(vec)
            pt = core:WorldToScreen(minion.pos)

            if(core:PointOnLineSegment(Vec2(pt1.x, pt1.y), Vec2(pt2.x, pt2.y), Vec2(pt.x, pt.y), radius)) then
                return true
            end

        end

    end

    return false
end

--Triggered right before OnUpdate
function OnPreUpdate() 
end

--Triggered right before OnUpdate.Main Logic should be called here!
function OnUpdate()
end

--Triggered after OnUpdate. All visuals of your Plugin should be handled here.
function OnDraw(ui) end

--Put all Settings in here
function DrawSettings(ui) 
    use_safe_mode = ui:Checkbox("Use Safemode", use_safe_mode)
    ui:Tooltip("[RECOMMENDED] The prediction will take longer, but will checks multiple factors to make sure you hit.")
end

--Triggered once a Unit recieves a buff.
function OnBuffGain(unit, buff) end

--Triggered once a Unit recalls.
function OnRecall(unit) end

--Triggered once a Unit teleports. Including special cases like Shen R.
function OnTeleport(unit) end

--Triggered once a Unit sets a new Path/does a new movement command.
function OnNewPath(waypoint, unit) 
 --   if(unit:IsEnemyTo(core:GetPlayer())) then
 --       test = unit.name
  --      new_waypoint_list[unit.name] = true
 --       core:DrawCircleWorld(waypoint, 100, 90, 1, Color(23/255,92/255,193/255,255))
  --  end

end

--Triggered once a Missile has been created (not all Spells are Missiles!!)
function OnMissile(missile) end

--Config loading should be handled here.
function LoadCfg(config) 
    use_safe_mode = config:GetBool("use_safe_mode", true)
end

--Config saving should be handled here.
function SaveCfg(config) 
    config:SetBool("use_safe_mode", use_safe_mode)
end

function OnPreOrbwalker() end

function OnPostOrbwalker() end

function GetDistanceSqr(core, p1, p2)
	local success, message = pcall(function() if p1 == nil then print(p1.x) end end)
	if not success then print(message) end
    p2 = p2 or core:GetPlayer()
    p1 = p1.pos or p1
    p2 = p2.pos or p2
    
    local dx, dz = p1.x - p2.x, p1.z - p2.z
    return dx * dx + dz * dz
end
 
function GetDistance(core, p1, p2)
    return math.sqrt(GetDistanceSqr(core,p1, p2))
end

function CalculateTargetPosition(core, unit, spell, tempPos)
    local delay, radius, speed, from = spell.Delay, spell.Radius, spell.Speed, core:GetPlayer().pos
    local calcPos = nil
    local pathCount = unit.path_count
    local pathIndex = unit.path_index
   -- print("pathCount:"..pathCount)
   -- print("index:"..pathIndex)
   local pathEndPos = unit.nav_end
   --  = unit.nav_end--Vec3(unit.nav_end.x, unit.nav_end.y, unit.nav_end.z) -- try at end with path count 
    local pathPos = tempPos and tempPos or unit.pos
    local pathPot = (unit.movement_speed * ((GetDistance(core, pathPos) / speed) + delay))
    local unitBR = unit.bounding_radius
    
    if pathCount < 2 then
        local extPos = unit.pos:Extend(pathEndPos, pathPot - unitBR)
        
        if unit.pos:Distance(extPos) > 0 then
            if unit.pos:Distance(pathEndPos) >= unit.pos:Distance(extPos) then
                calcPos = extPos
            else
                calcPos = pathEndPos
            end
        else
            calcPos = pathEndPos
        end
    else
        for i = pathIndex, pathCount do
            if unit:GetWaypoint(i) and unit:GetWaypoint(i - 1) then
                local startPos = i == pathIndex and unit.pos or unit:GetWaypoint(i - 1)
                local endPos = unit:GetWaypoint(i)
                local pathDist = startPos:Distance(endPos)
                --
                if unit:GetWaypoint(pathIndex - 1) then
                    if pathPot > pathDist then
                        pathPot = pathPot - pathDist
                    else
                        local extPos = startPos:Extend(endPos, pathPot - unitBR)
                        
                        calcPos = extPos
                        
                        if tempPos then
                            calcPos.y = 0
                            return calcPos, calcPos
                        else
                            
                            return CalculateTargetPosition(core, unit, spell, calcPos)
                        end
                    end
                end
            end
        end
        --
        if GetDistance(core, unit.pos,pathEndPos) > unitBR then
            calcPos = pathEndPos
        else
            calcPos = unit.pos
        end
    end
    
    calcPos = calcPos and calcPos or unit.pos
    
    if tempPos then
        calcPos.y = 0
        return calcPos,calcPos
    else
        return CalculateTargetPosition(core, unit, spell, calcPos)
    end
end


function VectorMovementCollision(startPoint1, endPoint1, v1, startPoint2, v2, delay)
    local sP1x, sP1y, eP1x, eP1y, sP2x, sP2y = startPoint1.x, startPoint1.z, endPoint1.x, endPoint1.z, startPoint2.x, startPoint2.z
    local d, e = eP1x - sP1x, eP1y - sP1y
    local dist, t1, t2 = math.sqrt(d * d + e * e), nil, nil
    local S, K = dist ~= 0 and v1 * d / dist or 0, dist ~= 0 and v1 * e / dist or 0
    local function GetCollisionPoint(t) return t and {x = sP1x + S * t, y = sP1y + K * t} or nil end
    if delay and delay ~= 0 then sP1x, sP1y = sP1x + S * delay, sP1y + K * delay end
    local r, j = sP2x - sP1x, sP2y - sP1y
    local c = r * r + j * j
    if dist > 0 then
        if v1 == huge then
            local t = dist / v1
            t1 = v2 * t >= 0 and t or nil
        elseif v2 == huge then
            t1 = 0
        else
            local a, b = S * S + K * K - v2 * v2, -r * S - j * K
            if a == 0 then
                if b == 0 then --c=0->t variable
                    t1 = c == 0 and 0 or nil
                else --2*b*t+c=0
                    local t = -c / (2 * b)
                    t1 = v2 * t >= 0 and t or nil
                end
            else --a*t*t+2*b*t+c=0
                local sqr = b * b - a * c
                if sqr >= 0 then
                    local nom = math.sqrt(sqr)
                    local t = (-nom - b) / a
                    t1 = v2 * t >= 0 and t or nil
                    t = (nom - b) / a
                    t2 = v2 * t >= 0 and t or nil
                end
            end
        end
    elseif dist == 0 then
        t1 = 0
    end
    return t1, GetCollisionPoint(t1), t2, GetCollisionPoint(t2), dist
end

function VectorPointProjectionOnLineSegment(v1, v2, v)
    local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
    local pointLine = Vec3(ax + rL * (bx - ax),0, ay + rL * (by - ay))
    local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
    local isOnSegment = rS == rL
    local pointSegment = isOnSegment and pointLine or Vec3(ax + rS * (bx - ax),0, ay + rS * (by - ay))
    return pointSegment, pointLine, isOnSegment
end

function mCollision(core, pos1, pos2, spell, list) --returns a table with minions (use #table to get count)
    local result, speed, width, delay, list = {}, spell.Speed, spell.Width + 65, spell.Delay, list
    --
    if not list then
        list = core.minions
    end
    --s
    for i = 1, #list do
        local m = list[i]
        local pos3 = delay and m.pos
        if m and m:IsEnemyTo(core:GetPlayer()) and m.is_alive and m.is_targetable and pos1:Distance(pos2) > pos1:Distance(pos3) then
            local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(pos1, pos2, pos3)
            if isOnSegment and pointSegment:Distance(pos3) < width * width then
                result[#result + 1] = m
            end
        end
    end
    return result
end

function IsImmobile(core, unit, spell)

    if( unit.velocity.x == 0 and unit.velocity.y == 0 and unit.velocity.z == 0 ) then return true, unit.pos, unit.pos  end

    if unit.movement_speed == 0 then return true, unit.pos, unit.pos end
    local delay, radius, speed, from = spell.Delay, spell.Radius, spell.Speed, core:GetPlayer().pos--spell.From.pos
    local debuff = {}
    for idx, buff in pairs(unit:GetBuffs()) do
        if buff.is_alive then
            local ExtraDelay = speed == math.huge and 0 or (from:Distance(unit.pos) / speed)
            if buff.end_time + (radius / unit.movement_speed) > core.time + delay + ExtraDelay then
                debuff[buff.type] = true
            end
        end
    end
    if debuff[5] or debuff[8] or debuff[12] or debuff[35] or
        debuff[23] or debuff[25] or debuff[30] then
        return true, unit.pos, unit.pos
    end
    return false, unit.pos, unit.pos
end
 
function IsSlowed(core, unit, spell)
    local delay, speed, from = spell.Delay, spell.Speed, spell.From.pos
    for idx, buff in pairs(unit:GetBuffs()) do
        if buff.type == 11 and buff.end_time >= core.time and buff.is_alive then
            if buff.end_time > Game.Timer() + delay + unit.pos:Distance(from) / speed then
                return true
            end
        end
    end
    return false
end

function IsDashing(core, unit, spell)
    local delay, radius, speed, from = spell.Delay, spell.Radius, spell.Speed, core:GetPlayer().pos--spell.From.pos
    local OnDash, CanHit, Pos = false, false, nil
    --
    if unit.is_dashing then
        local startPos = unit:GetWaypoint(0)    
        local endPos = unit:GetWaypoint(unit.path_count-1) 
        local dashSpeed = unit.current_dash_speed
        local timer = core.time
        local startT = timer - 30 / 2000
        local dashDist = GetDistance(core, startPos, endPos)
        local endT = startT + (dashDist / dashSpeed)
        --
        if endT >= timer and startPos and endPos then
            OnDash = true
            --
            local t1, p1, t2, p2, dist = VectorMovementCollision(startPos, endPos, dashSpeed, from, speed, (timer - startT) + delay)
            t1, t2 = (t1 and 0 <= t1 and t1 <= (endT - timer - delay)) and t1 or nil, (t2 and 0 <= t2 and t2 <= (endT - timer - delay)) and t2 or nil
            local t = t1 and t2 and min(t1, t2) or t1 or t2
            --
            if t then
                Pos = t == t1 and Vec3(p1.x, 0, p1.y) or Vec3(p2.x, 0, p2.y)
                CanHit = true
            else
                Pos = Vec3(endPos.x, 0, endPos.z)
                CanHit = (unit.movement_speed * (delay +  GetDistance(core, from, Pos) / speed - (endT - timer))) < radius
            end
        end
    end
    
    return OnDash, CanHit, Pos
end

Math = {}

function Math:Polar(p1)
	local x = p1.x
	local z = p1.z
	if x == 0 then
		if z > 0 then
			return 90
		end
		if z < 0 then
			return 270
		end
		return 0
	end
	local theta = math.atan(z / x) * (180.0 / math.pi) --RadianToDegree
	if x < 0 then
		theta = theta + 180
	end
	if theta < 0 then
		theta = theta + 3604
	end
	return theta
end

function Math:AngleBetween(p1, p2)
	if p1 == nil or p2 == nil then
		return nil
	end
	local theta = self:Polar(p1) - self:Polar(p2)
	if theta < 0 then
		theta = theta + 360
	end
	if theta > 180 then
		theta = 360 - theta
	end
	return theta
end

function GetBestCastPosition(core, unit, spell)

    ::retr::

    local Range = spell.Range and spell.Range - 30 or math.huge
    local radius = spell.Radius == 0 and 1 or (spell.Radius + unit.bounding_radius) - 4
    local speed = spell.Speed or math.huge
    local from = spell.From or core:GetPlayer()
    local delay = spell.Delay + (0.07 + 30 / 1000)
    local collision = spell.Collision or false
    local circular = spell.Circular or false
    --
    local Position, CastPosition, HitChance = unit.pos, unit.pos, 0
    local TargetDashing, CanHitDashing, DashPosition = IsDashing(core, unit, spell)
    local TargetImmobile, ImmobilePos, ImmobileCastPosition = IsImmobile(core, unit, spell)
    
    if TargetDashing then
        if CanHitDashing then
            HitChance = 5
        else
            HitChance = 0
        end
        Position, CastPosition = DashPosition, DashPosition
    elseif TargetImmobile then
        Position, CastPosition = ImmobilePos, ImmobileCastPosition
        HitChance = 4
    else

        if(circular == true) then
            Position, CastPosition = unit.pos, GetCirclePrediction(core, unit, Range, delay, radius)
        else
            Position, CastPosition = unit.pos, GetLinePred(core, unit, Range , speed, delay)
        end
        
        if GetDistanceSqr(core, from.pos, CastPosition) < 250 then
            HitChance = 2
            local newSpell = {Range = Range, Delay = delay * 0.5, Radius = radius, Width = radius, Speed = speed * 2, From = from}
            
            if(circular == true) then
                Position, CastPosition = unit.pos, GetCirclePrediction(core, unit, newSpell.Range, newSpell.Delay, newSpell.Radius)
            else
                Position, CastPosition = unit.pos, GetLinePred(core, unit, newSpell.Range , newSpell.Speed, newSpell.Delay)
            end

        end

        local temp_angle = unit.pos:AngleBetween(CastPosition)
        if temp_angle >= 60 then
            HitChance = 1
        elseif temp_angle <= 30 then
            HitChance = 2
        end
        
        if GetDistanceSqr(core, from.pos, CastPosition) >= Range * Range then
            HitChance = 0
        end

    end
   
    
    if collision and HitChance > 0 then
        local newSpell = {Range = Range, Delay = delay, Radius = radius * 2, Width = radius * 2, Speed = speed * 2, From = from}
        if #(mCollision(core, from.pos, CastPosition, newSpell)) > 0 then
            HitChance = 0
        end
    end
    
    --if(CastPosition:Length() <= 0) then return unit.pos, Vec3(0,0,0), 0 end

    return Position, CastPosition, HitChance
end