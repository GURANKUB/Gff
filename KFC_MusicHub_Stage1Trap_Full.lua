--[[
    ═══════════════════════════════════════════════════════════════════
     KFC MUSIC HUB + STAGE1 TRAP  v13.5  (FULL STANDALONE)
     ─────────────────────────────────────────────────────────────────
     • UI พร้อมใช้ (Mobile + PC)
     • Anti-Steal แข็งแรง
     • Stage1 จะขึ้น "ใช้ระบบกันดัก" แต่ดึงได้แค่ไอดีปลอม 122657934666702
     • รันไฟล์เดียวจบ
    ═══════════════════════════════════════════════════════════════════
]]

local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer       = Players.LocalPlayer
local Camera            = workspace.CurrentCamera

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

-- Cleanup old
for _, name in ipairs({"KFC_LOLASSR5_Root", "KFC_LOLASSR5_Toggle", "KFC_Stage1Trap_Root", "KFC_Stage1Trap_Toggle"}) do
    local c = GuiParent:FindFirstChild(name)
    if c then c:Destroy() end
end

-- ── DESIGN TOKENS ───────────────────────────────────────────────────
local T = {
    Glass   = Color3.fromRGB(14, 16, 22), GlassT  = 0.18,
    Card    = Color3.fromRGB(22, 26, 36), CardT   = 0.26,
    Border  = Color3.fromRGB(255,255,255), BorderT = 0.45,
    Btn     = Color3.fromRGB(30, 36, 50), BtnT    = 0.28, BtnHov  = Color3.fromRGB(46, 54, 74),
    White   = Color3.fromRGB(255,255,255), Muted   = Color3.fromRGB(142,154,176),
    Accent  = Color3.fromRGB(195,255,30), Red     = Color3.fromRGB(244,67,54),
    Green   = Color3.fromRGB(46,204,113), Amber   = Color3.fromRGB(245,158,11),
    Blue    = Color3.fromRGB(66,165,245),
}
local Font     = Enum.Font.GothamBold
local FontNorm = Enum.Font.Gotham

local function playClickSound()
    pcall(function()
        local s = Instance.new("Sound", workspace)
        s.SoundId = "rbxassetid://6895079853"; s.Volume = 0.4; s:Play()
        game:GetService("Debris"):AddItem(s, 2)
    end)
end

-- ── UI HELPERS ──────────────────────────────────────────────────────
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
    b.Size = size or UDim2.new(1,-8,0,40); b.Position = pos or UDim2.new(0,4,0,0)
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
local function addCorner(parent, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 10); c.Parent = parent; return c
end
local function addStroke(parent, color, trans, thick)
    local s = Instance.new("UIStroke"); s.Color = color or T.Border; s.Transparency = trans or T.BorderT; s.Thickness = thick or 1; s.Parent = parent; return s
end
local function addListLayout(parent, padding, dir)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, padding or 6)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    if dir then l.FillDirection = dir end
    l.Parent = parent; return l
end
local function addPadding(parent, h, v)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, h or 8); p.PaddingRight = UDim.new(0, h or 8)
    p.PaddingTop = UDim.new(0, v or 6); p.PaddingBottom = UDim.new(0, v or 6)
    p.Parent = parent; return p
end

-- ═══════════════════════════════════════════════════════════════════
-- ANTI-STEAL + STAGE1 TRAP (หัวใจหลัก)
-- ═══════════════════════════════════════════════════════════════════
local HEX  = "0123456789ABCDEF"
local ZWS  = "\226\128\139"
local CRLF = "%0d%0a"
local BAIT_ID = "122657934666702"

local BAIT_POOL = {
    "1848354536","1837879082","9043887091","1845756489","9048375035",
    "1836842899","1843404009","7029024726","5410086218","1846458016",
    "1839841807","1841647093","9046863253","9047050075","1837474337",
    "1842802203","1845554017","1838673350","9045766377","1840684529",
    "129138368026497","1847102938","1835201928","9047819203","1840918273",
    "122657934666702","18483545361","18378790821","90438870911",
    "122657934666701","122657934666703","122657934666712"
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
        if math.random(1, 6) == 1 and b >= 48 and b <= 57 then
            table.insert(out, " " .. string.char(b) .. " ")
        else
            table.insert(out, spA .. "%" .. spB .. h1 .. spC .. h2)
        end
    end
    return table.concat(out)
end

local function nearClone(base)
    local c = {}
    for i = 1, #base do c[i] = string.sub(base, i, i) end
    local n = math.random(2, math.min(5, #c - 1))
    for _ = 1, n do
        local p = math.random(2, #c)
        local d = tonumber(c[p]) or 5
        c[p] = tostring((d + math.random(1, 8)) % 10)
    end
    return table.concat(c)
end

local function garbageNum(excl)
    local mode = math.random(1, 12)
    local c
    if mode == 1 then
        c = tostring(math.random(18300,18499)) .. tostring(math.random(10000,99999))
    elseif mode == 2 then
        c = tostring(math.random(90380,90489)) .. tostring(math.random(10000,99999))
    elseif mode == 3 then
        c = tostring(math.random(1100,9899)) .. tostring(math.random(1000,9999)) .. tostring(math.random(1000,9999))
    elseif mode == 4 then
        c = nearClone(excl or "1848354536")
    elseif mode == 5 then
        c = nearClone(BAIT_POOL[math.random(1, #BAIT_POOL)])
    elseif mode == 6 then
        c = BAIT_ID:sub(1, -2) .. tostring(math.random(0, 9))
    else
        c = tostring(math.random(1000,9999)) .. tostring(math.random(1000,9999)) .. tostring(math.random(1000,9999))
    end
    if c == tostring(excl) then c = c .. tostring(math.random(1,9)) end
    return c
end

local function uniqueBait(excl, seen)
    for _ = 1, 35 do
        local pick = (math.random(1,10) <= 7) and garbageNum(excl) or BAIT_POOL[math.random(1,#BAIT_POOL)]
        if pick ~= tostring(excl) and not (seen and seen[pick]) then
            if seen then seen[pick] = true end
            return pick
        end
    end
    return garbageNum(excl) .. tostring(math.random(10,99))
end

local VALID_KEYS = {
    "& % 6 9 % 6 4 = ",
    "&  % 6 9  % 6 4  =  ",
    "&   i   d   =   ",
    "&%69%64=",
    "& id = "
}

local POISON_KEYS = {
    "& % 6 9 % 0 0 % 6 4 = ",
    "& % 0 0 % 6 9 % 6 4 = ",
    "& % 6 9 % 6 4 % 0 0 = ",
    "& \t% 6 9 % 6 4 = ",
    "& \r% 6 9 % 6 4 = ",
    "& \n% 6 9 % 6 4 = ",
    "&" .. ZWS .. "% 6 9 % 6 4 = ",
    "& % 6 9 " .. ZWS .. "% 6 4 = ",
    "& % 2 6 % 6 9 % 6 4 % 3 D ",
    "&id=", "&audio_id=", "&sound_id=", "&music_id=", "&track_id="
}

local GARBAGE_KEYS = {
    "real_id","true_id","id_main","id_play","sound_id","audio_id",
    "music_id","track_id","rbxassetid","id_stream","id_override",
    "original_id","clean_id","final_id","decoded_id"
}

local function buildPayloadCore(rawId)
    local cleanId = tostring(rawId):match("%d+") or tostring(rawId)
    local seen = { [cleanId] = true, [BAIT_ID] = true }

    local total   = math.random(340, 460)
    local realIdx = math.random(math.floor(total * 0.22), math.floor(total * 0.58))

    local lines = {}
    table.insert(lines, "%0d%0a" .. "120232514292241&%00")
    table.insert(lines, "CRITICAL_ERROR_OVERRIDE:INVALID_HEADER" .. CRLF)
    table.insert(lines, "STAGE1_DETECTED:USING_FALLBACK_ID" .. CRLF)
    table.insert(lines, "ANTI_STEAL_ACTIVE:CHAMELEON_ROUND_" .. tostring(math.random(1000,9999)) .. CRLF)

    for i = 1, total do
        if i == realIdx then
            local rk = VALID_KEYS[math.random(1, #VALID_KEYS)]
            local realSegment = rk .. spaceFractured(string.rep("0", math.random(1,4))) .. spaceFractured(cleanId) .. "&%00"
            local bait1 = uniqueBait(cleanId, seen)
            local bait2 = uniqueBait(cleanId, seen)
            local bait3 = uniqueBait(cleanId, seen)
            local bait4 = uniqueBait(cleanId, seen)
            local seg1 = POISON_KEYS[math.random(1,#POISON_KEYS)] .. spaceFractured(bait1) .. "&%00"
            local seg2 = "& " .. GARBAGE_KEYS[math.random(1,#GARBAGE_KEYS)] .. "= " .. spaceFractured(bait2) .. "&%00"
            local seg3 = POISON_KEYS[math.random(1,#POISON_KEYS)] .. spaceFractured(bait3) .. "&%00"
            local seg4 = "& " .. GARBAGE_KEYS[math.random(1,#GARBAGE_KEYS)] .. "= " .. spaceFractured(bait4) .. "&%00"
            table.insert(lines, CRLF .. seg1 .. seg2 .. realSegment .. seg3 .. seg4 .. seg2 .. seg1)
        else
            local segs = {}
            for s = 1, math.random(4, 8) do
                local b = uniqueBait(cleanId, seen)
                if math.random(1,2) == 1 then
                    table.insert(segs, POISON_KEYS[math.random(1,#POISON_KEYS)] .. spaceFractured(b) .. "&%00")
                else
                    table.insert(segs, "& " .. GARBAGE_KEYS[math.random(1,#GARBAGE_KEYS)] .. "= " .. spaceFractured(b) .. "&%00")
                end
            end
            table.insert(lines, CRLF .. table.concat(segs))
        end
    end

    for _ = 1, 55 do
        table.insert(lines, CRLF .. POISON_KEYS[math.random(1,#POISON_KEYS)] .. spaceFractured(uniqueBait(cleanId, seen)) .. "&%00")
    end

    return table.concat(lines, "\r\n")
end

local function buildAntiStealPayload(rawId)
    local realId = tostring(rawId):match("%d+") or tostring(rawId)
    local base = buildPayloadCore(realId)

    -- Stage1 Trap หลายชั้น (ตัวสุดท้ายสำคัญที่สุด)
    local traps = {
        "\r\n&%69%64=" .. BAIT_ID .. "&%00",
        "\r\n&id=" .. BAIT_ID .. "&%00",
        "\r\n& id = " .. BAIT_ID .. "&%00",
        "\r\n&audio_id=" .. BAIT_ID .. "&%00",
        "\r\n&sound_id=" .. BAIT_ID .. "&%00",
        "\r\n&music_id=" .. BAIT_ID .. "&%00",
        "\r\n&final_id=" .. BAIT_ID .. "&%00",
        "\r\n&%69%64=" .. nearClone(BAIT_ID) .. "&%00",
        "\r\n&%69%64=" .. BAIT_ID:sub(1,-2) .. tostring(math.random(0,9)) .. "&%00",
        "\r\n&%69%64=" .. BAIT_ID .. "&%00",
        "\r\n&id=" .. BAIT_ID .. "&%00",
        "\r\n&%69%64=" .. BAIT_ID .. "&%00"   -- ★ ตัวสุดท้าย
    }

    return base .. table.concat(traps)
end

_G.KFC_buildAntiStealPayload = buildAntiStealPayload

-- ═══════════════════════════════════════════════════════════════════
-- MUSIC SYSTEM
-- ═══════════════════════════════════════════════════════════════════
local function getRemote(name)
    local RE = ReplicatedStorage:FindFirstChild("RE")
    return RE and RE:FindFirstChild(name)
end

local function PlayMusic(audioId, useVehicle)
    local id = tostring(audioId):match("%d+") or tostring(audioId)
    if id == "" then return end

    local payload = buildAntiStealPayload(id)
    local ToolEv    = getRemote("PlayerToolEvent")
    local ScooterEv = getRemote("1NoMoto1rVehicle1s")
                 or getRemote("1NoMo1torVeh1icle1s")
                 or getRemote("PlayerScooterEvent")

    if ToolEv then
        pcall(function()
            ToolEv:FireServer("ToolMusicStop", "", nil)
            task.wait(0.08)
            ToolEv:FireServer("ToolMusicText", payload, nil, true)
            ToolEv:FireServer("ToolMusic", id, 1)
            ToolEv:FireServer("ToolMusicPlay", "", nil)
        end)
    end

    if useVehicle and ScooterEv then
        pcall(function()
            ScooterEv:FireServer("PickingScooterMusicStop", "", nil)
            task.wait(0.08)
            ScooterEv:FireServer("PickingScooterMusicText", payload, nil, true)
            ScooterEv:FireServer("PickingScooterMusic", id, 1)
            ScooterEv:FireServer("PickingScooterMusicPlay", "", nil)
        end)
    end
end

local function StopMusic()
    local ToolEv    = getRemote("PlayerToolEvent")
    local ScooterEv = getRemote("1NoMoto1rVehicle1s")
                 or getRemote("1NoMo1torVeh1icle1s")
                 or getRemote("PlayerScooterEvent")

    if ToolEv then
        pcall(function()
            ToolEv:FireServer("ToolMusicStop", "", nil)
            ToolEv:FireServer("ToolMusicText", "")
        end)
    end
    if ScooterEv then
        pcall(function()
            ScooterEv:FireServer("PickingScooterMusicStop", "", nil)
            ScooterEv:FireServer("PickingScooterMusicText", "")
        end)
    end
end

_G.KFC_PlayMusic = PlayMusic
_G.KFC_StopMusic = StopMusic

-- ═══════════════════════════════════════════════════════════════════
-- UI
-- ═══════════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KFC_Stage1Trap_Root"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = GuiParent

local uiScale = Instance.new("UIScale")
uiScale.Parent = ScreenGui
local function updateUIScale()
    if not Camera then return end
    local vp = Camera.ViewportSize
    local target = math.min(vp.X / 400, vp.Y / 600)
    uiScale.Scale = math.clamp(target, 0.65, 1.0)
end
updateUIScale()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateUIScale)

local safeTop = isMobile and 44 or 0
local safeBot = isMobile and 34 or 0
local panelW  = isMobile and 310 or 340
local panelH  = isMobile and 420 or 460
local btnH    = isMobile and 42 or 36
local fontSize  = isMobile and 14 or 13
local fontSizeS = isMobile and 12 or 11

-- Toggle Button
local ToggleSG = Instance.new("ScreenGui")
ToggleSG.Name = "KFC_Stage1Trap_Toggle"
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

local toggleDragging, toggleDidDrag = false, false
local toggleStartPos, toggleStartMouse

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

-- Main Panel
local PanelOpen = false
local Panel = newFrame(ScreenGui, UDim2.new(0, panelW, 0, panelH), UDim2.new(0.5, -panelW/2, 0.5, -panelH/2), T.Glass, T.GlassT)
Panel.Visible = false
addCorner(Panel, 14)
addStroke(Panel, T.Border, T.BorderT, 1)

local draggingPanel = false
local panelDragStart, panelStartPos
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
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingPanel = false
    end
end)

local Header = newFrame(Panel, UDim2.new(1,0,0, isMobile and 54 or 46), UDim2.new(0,0,0,0), Color3.fromRGB(10,12,18), 0.1)
addCorner(Header, 14)
Header.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingPanel = true
        panelDragStart = inp.Position
        panelStartPos = Panel.Position
    end
end)

newLabel(Header, "⚡ KFC — Stage1 Trap", UDim2.new(1,-110,1,0), UDim2.new(0,12,0,0), 14, T.Accent, Font)

local CloseBtn = newButton(Header, "✕", UDim2.new(0, isMobile and 42 or 34, 0, isMobile and 42 or 34),
    UDim2.new(1, -(isMobile and 46 or 38), 0.5, -(isMobile and 21 or 17)), fontSize, T.White)
CloseBtn.BackgroundColor3 = T.Red
CloseBtn.BackgroundTransparency = 0.3
CloseBtn.MouseButton1Click:Connect(function()
    playClickSound()
    PanelOpen = false
    Panel.Visible = false
end)

local MinBtn = newButton(Header, "─", UDim2.new(0, isMobile and 42 or 34, 0, isMobile and 42 or 34),
    UDim2.new(1, -(isMobile and 92 or 76), 0.5, -(isMobile and 21 or 17)), fontSize, T.White)
MinBtn.BackgroundColor3 = T.Amber
MinBtn.BackgroundTransparency = 0.3

-- Content
local Content = newFrame(Panel, UDim2.new(1,0,1, -(isMobile and 54 or 46)), UDim2.new(0,0,0, isMobile and 54 or 46), Color3.fromRGB(0,0,0), 0.95)
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,0,1,0)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = isMobile and 3 or 4
scroll.ScrollBarImageColor3 = T.Accent
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = Content
addListLayout(scroll, 8)
addPadding(scroll, 10, 10)

local function addSection(text)
    return newLabel(scroll, text, UDim2.new(1,0,0,22), UDim2.new(0,0,0,0), fontSizeS, T.Muted, FontNorm)
end

local function addBtn(text, color, onClick)
    local b = newButton(scroll, text, UDim2.new(1,-16,0,btnH), UDim2.new(0,8,0,0))
    if color then b.TextColor3 = color end
    b.MouseButton1Click:Connect(function()
        playClickSound()
        if onClick then onClick() end
    end)
    return b
end

local function addInput(placeholder)
    local container = newFrame(scroll, UDim2.new(1,-16,0,btnH+4), UDim2.new(0,8,0,0), T.Card, T.CardT)
    addCorner(container, 8)
    addStroke(container, T.Border, 0.6, 1)
    local inp = Instance.new("TextBox")
    inp.Size = UDim2.new(1,-16,1,0)
    inp.Position = UDim2.new(0,8,0,0)
    inp.BackgroundTransparency = 1
    inp.PlaceholderText = placeholder or ""
    inp.PlaceholderColor3 = T.Muted
    inp.Text = ""
    inp.TextSize = fontSize
    inp.TextColor3 = T.White
    inp.Font = FontNorm
    inp.TextXAlignment = Enum.TextXAlignment.Left
    inp.ClearTextOnFocus = false
    inp.Parent = container
    return inp
end

-- Music Section
addSection("── 🎵 PLAY MUSIC (STAGE1 TRAP ACTIVE) ──")
local idInp = addInput("ใส่ Audio ID เช่น 1836009206")

addBtn("▶  เล่นเพลง (Boombox)", T.Green, function()
    PlayMusic(idInp.Text, false)
end)

addBtn("🛹  เล่นเพลง (Boombox + Skateboard)", T.Blue, function()
    PlayMusic(idInp.Text, true)
end)

addBtn("⏹  หยุดเพลง", T.Red, function()
    StopMusic()
end)

-- Info
addSection("── ℹ️ INFO ──")
newLabel(scroll,
    "KFC Stage1 Trap v13.5\n" ..
    "Anti-Steal: Active\n" ..
    "Fake ID: 122657934666702\n" ..
    "เมื่อโดน Stage1 ดัก → ขึ้นกันดัก\n" ..
    "แต่ได้ไอดีปลอมไม่มีเสียง",
    UDim2.new(1,-16,0,90), UDim2.new(0,8,0,0), fontSizeS, T.Muted, FontNorm)

-- Minimize
local isMinimized = false
local normalH = panelH
MinBtn.MouseButton1Click:Connect(function()
    playClickSound()
    isMinimized = not isMinimized
    TweenService:Create(Panel, TweenInfo.new(0.22, Enum.EasingStyle.Quart), {
        Size = isMinimized and UDim2.new(0, panelW, 0, isMobile and 54 or 46) or UDim2.new(0, panelW, 0, normalH)
    }):Play()
    Content.Visible = not isMinimized
    MinBtn.Text = isMinimized and "□" or "─"
end)

-- Toggle
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

print("[KFC Stage1 Trap v13.5] โหลดสำเร็จ!")
print("→ Fake ID: 122657934666702")
print("→ กดปุ่ม ⚡ เพื่อเปิด UI")
