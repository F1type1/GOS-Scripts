require 'MapPositionGOS'

if (myHero.charName ~= "Nocturne") then 
    return
end

if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
	print("GsoPred. installed Press 2x F6")
	DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GOS-External/master/Common/GamsteronPrediction.lua", COMMON_PATH .. "GamsteronPrediction.lua", function() end)
	while not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") do end
end
    
require('GamsteronPrediction')

local  TS, OB, DMG, SPELLS
local myHero = myHero
local LocalGameTimer = Game.Timer
GamCore = _G.GamsteronCore

local lineQ

local function IsValid(unit)
    if (unit 
        and unit.valid 
        and unit.isTargetable 
        and unit.alive 
        and unit.visible 
        and unit.networkID 
        and unit.health > 0) then
        return true;
    end
    return false;
end

local function Ready(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana and Game.CanUseSpell(spell) == 0
end

class "Nocturne"
function Nocturne:__init()
   ORB, TS, OB, DMG, SPELLS = _G.SDK.Orbwalker, _G.SDK.TargetSelector, _G.SDK.ObjectManager, _G.SDK.Damage, _G.SDK.Spells
   self.LastReset = 0
    self.QData = {Type = _G.SPELLTYPE_LINE, Delay = 0.25, width = myHero:GetSpellData(_Q).width, Range = 1200, Speed = 1600}
    self:LoadMenu()
    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)
end

function Nocturne:LoadMenu()
    LL = MenuElement({type = MENU, id = "ll", name = "Nocturne"})
    
class "Nocturne"
function Nocturne:__init()
   ORB, TS, OB, DMG, SPELLS = _G.SDK.Orbwalker, _G.SDK.TargetSelector, _G.SDK.ObjectManager, _G.SDK.Damage, _G.SDK.Spells
   self.LastReset = 0
    self.EData = {range = 425, width = myHero:GetSpellData(_E).width, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed}
    self:LoadMenu()
    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)
end

function Nocturne:LoadMenu()
    LL = MenuElement({type = MENU, id = "12", name = "Nocturne"})
    
class "Nocturne"
function Nocturne:__init()
   ORB, TS, OB, DMG, SPELLS = _G.SDK.Orbwalker, _G.SDK.TargetSelector, _G.SDK.ObjectManager, _G.SDK.Damage, _G.SDK.Spells
   self.LastReset = 0
    self.RData = {range = 2500, range = 3250, range = 4000, width = myHero:GetSpellData(_R).width, delay = myHero:GetSpellData(_R).delay, speed = math.huge}
    self:LoadMenu()
    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)
end

function Nocturne:LoadMenu()
    LL = MenuElement({type = MENU, id = "13", name = "Nocturne"})    
  
  --combo
    LL:MenuElement({type = MENU, id = "Combo", name = "Combo"})
    LL.Combo:MenuElement({name = "Use spell on:", id = "useon", type = _G.MENU})
    GamCore:OnEnemyHeroLoad(function(hero) LL.Combo.useon:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)
    LL.Combo:MenuElement({id = "UseR", name = "[R]", value = true})
    LL.Combo:MenuElement({id = "UseR", name = "[R]", value = true})
    LL.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
    LL.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
    
  
 
   --Auto
    LL:MenuElement({type = MENU, id = "Auto", name = "Auto"})
    LL.Auto:MenuElement({id = "AutoIG", name = "Auto Ingite KS", value = true})
    LL.Auto:MenuElement({id = "AutoIG", name = "Auto Smite KS", value = true})


    --Draw
    LL:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
    LL.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
    LL.Drawing:MenuElement({id = "R", name = "Draw [R] Range", value = true})  


end

function Nocturne:Draw()
    if myHero.dead then
        return
  end
--[[
    if lineQ ~= nil then
        lineQ:__draw(1)
    end
--]]

    if LL.Drawing.Q:Value() and Ready(_Q) then
        Draw.Circle(myHero.pos, 1200,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
      
--[[
    if lineR ~= nil then
        lineR:__draw(1)
    end
--]]  
      
      if LL.Drawing.R:Value() and Ready(_R) then
        Draw.Circle(myHero.pos, 2500,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end 

end


local NextTick = GetTickCount()
function Nocturne:Tick()
    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end
  
  self:Auto()
    if NextTick > GetTickCount() then return end
    ORB:SetMovement(true)
    if ORB.Modes[0] then --combo
        self:Combo()
    elseif ORB.Modes[1] then --harass
        self:Harass()
    end

end

function Nocturne:Combo()
    local EnemyHeroes = OB:GetEnemyHeroes(2500, false)
    local targetList = {}

    for i = 1, #EnemyHeroes do
        local hero = EnemyHeroes[i]
        local heroName = hero.charName
        if LL.Combo.useon[heroName] and LL.Combo.useon[heroName]:Value() then
            targetList[#targetList + 1] = hero
        end
    end
    local target = TS:GetTarget(targetList)
    if target == nil then return end

  
   if IsValid(target) then
        if LL.Combo.UseR:Value() and Ready(_R) and myHero.pos:DistanceTo(target.pos) <= 2500 then

            local Pred = GetGamsteronPrediction(target, self.RData, myHero)
            if Pred.Hitchance >= _G.HITCHANCE_HIGH then
                (Pred.CastPosition, Pred.CastPosition:Extended(myHero.pos, myHero.pos:DistanceTo(target.pos)))
                end
                NextTick = GetTickCount() + 250
                ORB:SetMovement(false)
                Control.CastSpell(HK_R, Pred.CastPosition)
            end
        end

        if LL.Combo.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) <= 1200 then

            local Pred = GetGamsteronPrediction(target, self.QData, myHero)
            if Pred.Hitchance >= _G.HITCHANCE_HIGH then
                lineQ = LineSegment(Pred.CastPosition, Pred.CastPosition:Extended(myHero.pos, myHero.pos:DistanceTo(target.pos)))
                end
        end



        if LL.Combo.UseE:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 425 then
            Control.CastSpell(HK_E)
     end


    end

end
  
function Nocturne:Harass()
  local EnemyHeroes = OB:GetEnemyHeroes(1100, false)
    local targetList = {}

    for i = 1, #EnemyHeroes do
        local hero = EnemyHeroes[i]
        local heroName = hero.charName
        if LL.Harass.useon[heroName] and LL.Harass.useon[heroName]:Value() then
            targetList[#targetList + 1] = hero
        end
    end
    local target = TS:GetTarget(targetList)
    if target == nil then return end

    if IsValid(target) then

        if LL.Harass.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) <= 1100 then
            local Pred = GetGamsteronPrediction(target, self.QData, myHero)
            if Pred.Hitchance >= _G.HITCHANCE_HIGH then
                lineQ = LineSegment(Pred.CastPosition, Pred.CastPosition:Extended(myHero.pos, myHero.pos:DistanceTo(target.pos)))
                if MapPosition:intersectsWall(lineQ) then
                    return
                end
                NextTick = GetTickCount() + 250
                ORB:SetMovement(false)
                Control.CastSpell(HK_Q, Pred.CastPosition)
            end
        end

    end

end
  
  function Nocturne:Auto()
    local IGdamage = 50 + 20 * myHero.levelData.lvl
    local target = TS:GetTarget(600)
    if target == nil then return end
    if LL.Auto.AutoIG:Value() then
        if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and myHero:GetSpellData(SUMMONER_1).currentCd == 0 then
            if IGdamage >= target.health then
                Control.CastSpell(HK_SUMMONER_1, target.pos)
            end
        end
        

        if myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and myHero:GetSpellData(SUMMONER_2).currentCd == 0 then
            if IGdamage >= target.health then
                Control.CastSpell(HK_SUMMONER_2, target.pos)
            end
        end
    end

end


function OnLoad()
    _G[myHero.charName]()
end
  
