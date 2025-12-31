-- =========================
-- EXPLODE | FULL SCRIPT (UI EXATAMENTE COMO VOCÊ ENVIOU + FUNCIONALIDADE)
-- =========================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local enabled = false
local loopConnection
local index = 0

-- =========================
-- EXPLODE FUNCTIONS (150x, origem 1 stud abaixo)
-- =========================

local function getWaist(character)
    return character:FindFirstChild("HumanoidRootPart")
        or character:FindFirstChild("LowerTorso")
        or character:FindFirstChild("UpperTorso")
end

local function fireMassPlayers()
    local tool =
        LocalPlayer.Backpack:FindFirstChild("RocketJumper")
        or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("RocketJumper"))

    if not tool or not tool:FindFirstChild("FireRocket") then return end

    local players = Players:GetPlayers()
    if #players <= 1 then return end

    local count = 0
    local maxPerFrame = 150

    repeat
        index += 1
        if index > #players then
            index = 1
        end

        local targetPlayer = players[index]
        if targetPlayer ~= LocalPlayer and targetPlayer.Character then
            local waist = getWaist(targetPlayer.Character)
            if waist then
                local origin = waist.Position - Vector3.new(0, 1, 0)  -- 1 stud abaixo
                local target = waist.Position + Vector3.new(0, 1, 0)

                tool.FireRocket:FireServer(origin, target)
                count += 1
            end
        end
    until count >= maxPerFrame or count >= #players - 1
end

local function startLoop()
    if loopConnection then return end
    loopConnection = RunService.Heartbeat:Connect(function()
        if enabled then
            fireMassPlayers()
        end
    end)
end

local function stopLoop()
    if loopConnection then
        loopConnection:Disconnect()
        loopConnection = nil
    end
end

-- =========================
-- GUI EXATAMENTE COMO VOCÊ ENVIOU (SEM NENHUMA ALTERAÇÃO VISUAL)
-- =========================

local gui = Instance.new("ScreenGui")
gui.Name = "ExplodeUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- MAIN FRAME
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 110, 0, 30)
main.Position = UDim2.new(1, -140, 0.25, 0)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = false
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

-- ORANGE NEON BORDER
local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2.5
stroke.Color = Color3.fromRGB(255, 140, 0)
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- =========================
-- DRAG SYSTEM (EXATAMENTE COMO VOCÊ ENVIOU)
-- =========================
local dragging = false
local dragStart
local startPos

main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

main.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 50, 1, 0)
title.Position = UDim2.new(0, 6, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Explode"
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextColor3 = Color3.fromRGB(255, 220, 190)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

-- SWITCH (fundo)
local switch = Instance.new("Frame")
switch.Size = UDim2.new(0, 34, 0, 18)
switch.Position = UDim2.new(1, -38, 0.5, -9)
switch.BackgroundColor3 = Color3.fromRGB(255, 40, 40)  -- OFF (vermelho)
switch.BorderSizePixel = 0
switch.Parent = main
Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

-- KNOB (bolinha do switch)
local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 14, 0, 14)
knob.Position = UDim2.new(0, 2, 0.5, -7)  -- posição OFF
knob.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
knob.BorderSizePixel = 0
knob.Parent = switch
Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

-- =========================
-- TOGGLE (CLIQUE DIRETO NO SWITCH - EXATAMENTE COMO VOCÊ ENVIOU)
-- =========================
switch.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		enabled = not enabled

		if enabled then
			-- Liga (laranja)
			TweenService:Create(switch, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(255, 170, 0)
			}):Play()

			TweenService:Create(knob, TweenInfo.new(0.2), {
				Position = UDim2.new(1, -16, 0.5, -7)
			}):Play()

			startLoop()  -- ATIVA O EXPLODE

		else
			-- Desliga (vermelho)
			TweenService:Create(switch, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(255, 40, 40)
			}):Play()

			TweenService:Create(knob, TweenInfo.new(0.2), {
				Position = UDim2.new(0, 2, 0.5, -7)
			}):Play()

			stopLoop()  -- DESATIVA O EXPLODE
		end
	end
end)
