local allowedPlaceId = 126911378016560
local isAllowedGame = (game.PlaceId == allowedPlaceId)

if not isAllowedGame then
	LocalPlayer:Kick("Tu l'as executé sur un jeu random, Merci d'utiliser le scr1pt sur le jeu indiqué.")
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Nexus Scripts Present: Site 62 FR RP [V2]",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Loading...",
   LoadingSubtitle = "by G9pw",
   ShowText = "NXS", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "DarkBlue", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local Tab = Window:CreateTab("・Combat・", "crosshair")
local Section = Tab:CreateSection("--- Combat ---")

local Paragraph = Tab:CreateParagraph({Title = "ReadMe", Content = "Why isn't it working? ---> Disable WallCheck"})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local AimbotEnabled = false
local FOVVisible = true
local AimbotSmooth = 0.15
local Prediction = 0.15
local FOVRadius = 125
local AimPart = "Head"
local WallCheck = false
local TeamCheck = false

local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOVCircle.Radius = FOVRadius
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Visible = false
FOVCircle.Transparency = 0.7
FOVCircle.Thickness = 3
FOVCircle.NumSides = 64

local function GetClosestPlayer()
	local closest = nil
	local shortest = FOVRadius

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPart) then
			if TeamCheck and player.Team == LocalPlayer.Team then continue end
			if player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health <= 0 then continue end

			local part = player.Character[AimPart]
			local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)

			if onScreen then
				if WallCheck then
					local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 500)
					local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character, false, true)
					if hit and not hit:IsDescendantOf(player.Character) then continue end
				end

				local predictedPos = part.Position + (player.Character.HumanoidRootPart.Velocity * Prediction)
				local distance = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
				if distance < shortest then
					shortest = distance
					closest = predictedPos
				end
			end
		end
	end

	return closest
end

RunService.RenderStepped:Connect(function()
	FOVCircle.Position = UserInputService:GetMouseLocation()
	FOVCircle.Radius = FOVRadius
	FOVCircle.Visible = FOVVisible and AimbotEnabled

	if AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		local target = GetClosestPlayer()
		if target then
			Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target), 1 - AimbotSmooth)
		end
	end
end)

Tab:CreateToggle({
	Name = "・Enable Aimbot",
	CurrentValue = false,
	Flag = "AimbotToggle",
	Callback = function(Value)
		AimbotEnabled = Value
	end,
})

Tab:CreateDropdown({
	Name = "・Body Part",
	Options = {"Head", "Torso", "HumanoidRootPart", "LeftArm", "RightArm", "LeftLeg", "RightLeg"},
	CurrentOption = {"Head"},
	MultipleOptions = false,
	Flag = "AimPartDropdown",
	Callback = function(Options)
		AimPart = Options[1]
	end,
})

Tab:CreateSlider({
	Name = "・Smooth",
	Range = {0, 1},
	Increment = 0.05,
	CurrentValue = AimbotSmooth,
	Flag = "SmoothSlider",
	Callback = function(Value)
		AimbotSmooth = Value
	end,
})

Tab:CreateSlider({
	Name = "・Prediction",
	Range = {0, 1},
	Increment = 0.05,
	CurrentValue = Prediction,
	Flag = "PredictionSlider",
	Callback = function(Value)
		Prediction = Value
	end,
})

Tab:CreateToggle({
	Name = "・FOV Visibility",
	CurrentValue = true,
	Flag = "FOVVisibleToggle",
	Callback = function(Value)
		FOVVisible = Value
	end,
})

Tab:CreateSlider({
	Name = "・FOV Radius",
	Range = {20, 300},
	Increment = 5,
	CurrentValue = FOVRadius,
	Flag = "FOVSizeSlider",
	Callback = function(Value)
		FOVRadius = Value
	end,
})

Tab:CreateToggle({
	Name = "・Wall Check",
	CurrentValue = false,
	Flag = "WallCheckToggle",
	Callback = function(Value)
		WallCheck = Value
	end,
})

Tab:CreateToggle({
	Name = "・Team Check",
	CurrentValue = false,
	Flag = "TeamCheckToggle",
	Callback = function(Value)
		TeamCheck = Value
	end,
})

Tab:CreateColorPicker({
	Name = "・FOV Color",
	Color = Color3.fromRGB(255, 0, 0),
	Flag = "FOVColorPicker",
	Callback = function(Value)
		FOVCircle.Color = Value
	end,
})

local Tab = Window:CreateTab("・Visuals・", "view")
local Section = Tab:CreateSection("--- Visuals ---")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local espEnabled = false
local espConnections = {}
local trackedPlayers = {}

local function clearESP(player)
	if player == LocalPlayer then return end
	if player.Character then
		for _, obj in pairs(player.Character:GetDescendants()) do
			if obj:IsA("Highlight") and obj.Name == "ESPHighlight" then
				obj:Destroy()
			end
		end
		local head = player.Character:FindFirstChild("Head")
		if head then
			for _, obj in pairs(head:GetChildren()) do
				if obj:IsA("BillboardGui") and obj.Name == "ESPNameTag" then
					obj:Destroy()
				end
			end
		end
	end
end

local function applyHighlight(player)
	if player == LocalPlayer or not player.Character or not player.Character:FindFirstChild("Head") then return end
	clearESP(player)

	local character = player.Character
	local head = character.Head
	local teamColor = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)

	local contourColor = Color3.new(
		math.clamp(teamColor.R * 0.35, 0, 1),
		math.clamp(teamColor.G * 0.35, 0, 1),
		math.clamp(teamColor.B * 0.35, 0, 1)
	)

	local highlight = Instance.new("Highlight")
	highlight.Name = "ESPHighlight"
	highlight.Adornee = character
	highlight.FillColor = teamColor
	highlight.FillTransparency = 0.4
	highlight.OutlineColor = contourColor
	highlight.OutlineTransparency = 0.05
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = character

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESPNameTag"
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 70, 0, 14)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = teamColor
	label.TextStrokeColor3 = Color3.new(0, 0, 0)
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.GothamSemibold
	label.TextScaled = true
	label.Text = player.Name .. " | (" .. tostring(player.Team and player.Team.Name or "Unknown") .. ")"
	label.Parent = billboard

	local connection = RunService.RenderStepped:Connect(function()
		local localChar = LocalPlayer.Character
		if localChar and localChar:FindFirstChild("Head") then
			local distance = (localChar.Head.Position - head.Position).Magnitude
			local scale = math.clamp(70 / distance, 0.4, 2.2)
			billboard.Size = UDim2.new(0, 70 * scale, 0, 14 * scale)
		end
	end)

	table.insert(espConnections, connection)
	trackedPlayers[player] = player.Team
end

local function hookPlayer(player)
	if player == LocalPlayer then return end

	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		if espEnabled then
			applyHighlight(player)
		end
	end)

	player:GetPropertyChangedSignal("Team"):Connect(function()
		if espEnabled and player.Character and player.Character:FindFirstChild("Head") then
			applyHighlight(player)
		end
	end)
end

for _, player in ipairs(Players:GetPlayers()) do
	hookPlayer(player)
end

Players.PlayerAdded:Connect(function(player)
	hookPlayer(player)
	if espEnabled and player.Character and player.Character:FindFirstChild("Head") then
		task.wait(0.5)
		applyHighlight(player)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	trackedPlayers[player] = nil
end)

Tab:CreateToggle({
	Name = "・ESP Chams",
	CurrentValue = false,
	Flag = "ESPChamsFinal",
	Callback = function(state)
		espEnabled = state

		if state then
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
					applyHighlight(player)
				end
			end
		else
			for _, player in ipairs(Players:GetPlayers()) do
				clearESP(player)
			end
			for _, conn in pairs(espConnections) do
				conn:Disconnect()
			end
			espConnections = {}
			trackedPlayers = {}
		end
	end,
})

local Tab = Window:CreateTab("・Utilitaires・", "cog")
local Section = Tab:CreateSection("--- Utilitaires ---")

Tab:CreateButton({
    Name = "・Fling All",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/5m2Z9TmR"))()
    end,
})

local Section = Tab:CreateSection("Local Player Mods")

getgenv().FlySpeed = 50

local cloneref = cloneref or function(...) return ... end
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))

local lp = Players.LocalPlayer
local flying = false
local bv, bav
local buttons = {W = false, S = false, A = false, D = false, Moving = false}

local function StartFly()
    if not lp.Character then return end
    local c = lp.Character
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h or flying then return end

    h.PlatformStand = true
    local cam = workspace.CurrentCamera

    bv = Instance.new("BodyVelocity")
    bav = Instance.new("BodyAngularVelocity")

    bv.Velocity, bv.MaxForce, bv.P = Vector3.new(0, 0, 0), Vector3.new(10000, 10000, 10000), 1000
    bav.AngularVelocity, bav.MaxTorque, bav.P = Vector3.new(0, 0, 0), Vector3.new(10000, 10000, 10000), 1000
    bv.Parent = c.Head
    bav.Parent = c.Head

    flying = true

    h.Died:Connect(function()
        EndFly()
    end)
end

local function EndFly()
    if bv then bv:Destroy() end
    if bav then bav:Destroy() end

    local c = lp.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if h then h.PlatformStand = false end

    flying = false
end

UserInputService.InputBegan:Connect(function(input, GPE)
    if GPE then return end
    for i, _ in pairs(buttons) do
        if i ~= "Moving" and input.KeyCode == Enum.KeyCode[i] then
            buttons[i] = true
            buttons.Moving = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, GPE)
    if GPE then return end
    local stillMoving = false
    for i, _ in pairs(buttons) do
        if i ~= "Moving" and input.KeyCode == Enum.KeyCode[i] then
            buttons[i] = false
        end
        if buttons[i] then stillMoving = true end
    end
    buttons.Moving = stillMoving
end)

local function setVec(vec)
    return vec * ((getgenv().FlySpeed or 50) / vec.Magnitude)
end

RunService.Heartbeat:Connect(function(step)
    local c = cloneref(lp.Character)
    if flying and c and c.PrimaryPart then
        local p = c.PrimaryPart.Position
        local cf = workspace.CurrentCamera.CFrame
        local ax, ay, az = cf:ToEulerAnglesXYZ()
        c:SetPrimaryPartCFrame(CFrame.new(p.x, p.y, p.z) * CFrame.Angles(ax, ay, az))
        if buttons.Moving then
            local t = Vector3.zero
            if buttons.W then t += setVec(cf.LookVector) end
            if buttons.S then t -= setVec(cf.LookVector) end
            if buttons.A then t -= setVec(cf.RightVector) end
            if buttons.D then t += setVec(cf.RightVector) end
            c:TranslateBy(t * step)
        end
    end
end)

Tab:CreateToggle({
    Name = "・Enable Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(state)
        if state then
            StartFly()
        else
            EndFly()
        end
    end,
})

Tab:CreateSlider({
    Name = "・Fly Speed",
    Range = {10, 350},
    Increment = 5,
    Suffix = "Speed",
    CurrentValue = getgenv().FlySpeed,
    Flag = "FlySpeedSlider",
    Callback = function(value)
        getgenv().FlySpeed = value
    end,
})

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local Slider = Tab:CreateSlider({
    Name = "・Walkspeed",
    Range = {0, 250},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "SliderWalkSpeed",
    Callback = function(Value)
        if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
            localPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end,
})

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local function setJumpPower(value)
    if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
        localPlayer.Character.Humanoid.JumpPower = value
        localPlayer.Character.Humanoid.UseJumpPower = true
    end
end

local Slider = Tab:CreateSlider({
    Name = "・JumpPower",
    Range = {0, 250},
    Increment = 5,
    Suffix = "Jump",
    CurrentValue = 50,
    Flag = "SliderJumpPower",
    Callback = function(Value)
        setJumpPower(Value)
    end,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local noclipConnection

Tab:CreateToggle({
    Name = "・Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(state)
        if state then
            noclipConnection = RunService.Stepped:Connect(function()
                if localPlayer.Character then
                    for _, part in pairs(localPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            if localPlayer.Character then
                for _, part in pairs(localPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end,
})

local Section = Tab:CreateSection("Tp Everyone")

local tpAllToMeConnection = nil
local playerPositions = {}

local Toggle = Tab:CreateToggle({
   Name = "・TP Everyone En Boucle (Client)",
   CurrentValue = false,
   Flag = "ToggleCircleFormation",
   Callback = function(Value)
      if Value then
         local localPlayer = game.Players.LocalPlayer
         local localCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()
         local myHRP = localCharacter:FindFirstChild("HumanoidRootPart")
         if not myHRP then return end

         local function calculateCirclePositions()
            local players = {}
            for _, player in ipairs(game.Players:GetPlayers()) do
               if player ~= localPlayer and player.Character then
                  table.insert(players, player)
               end
            end

            local count = #players
            local radius = math.min(5 + (count * 0.5), 20)
            local angleStep = (math.pi * 2) / math.max(count, 1)

            for i, player in ipairs(players) do
               local angle = angleStep * (i - 1)
               local x = math.cos(angle) * radius
               local z = math.sin(angle) * radius
               playerPositions[player] = Vector3.new(x, 0, z)
            end
         end

         local function positionPlayer(player, offset)
            if not player.Character then return end
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            local myHRP = localCharacter:FindFirstChild("HumanoidRootPart")
            if targetHRP and myHRP then
               local targetCFrame = CFrame.new(myHRP.Position + offset) * CFrame.Angles(0, math.atan2(offset.X, offset.Z), 0)
               targetHRP.CFrame = targetCFrame
            end
         end

         local function updateAllPositions()
            calculateCirclePositions()
            for player, offset in pairs(playerPositions) do
               if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                  positionPlayer(player, offset)
               end
            end
         end

         calculateCirclePositions()
         tpAllToMeConnection = game:GetService("RunService").Heartbeat:Connect(updateAllPositions)

         local function onPlayerAdded(player)
            player.CharacterAdded:Connect(function()
               if Toggle:GetValue() then
                  task.wait(0.5)
                  calculateCirclePositions()
               end
            end)
         end

         game.Players.PlayerAdded:Connect(onPlayerAdded)

      else
         if tpAllToMeConnection then
            tpAllToMeConnection:Disconnect()
            tpAllToMeConnection = nil
         end
      end
   end,
})

local Section = Tab:CreateSection("TP Target")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local targetName = ""

Tab:CreateInput({
    Name = "・TP to Player",
    PlaceholderText = "Nom ou DisplayName...",
    Flag = "TPInput",
    Callback = function(text)
        targetName = text:lower()
    end,
})

Tab:CreateButton({
    Name = "・Confirmer TP",
    Callback = function()
        if targetName == "" then return end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                if plr.Name:lower():match("^" .. targetName) or plr.DisplayName:lower():match("^" .. targetName) then
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local myChar = LocalPlayer.Character
                    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

                    if hrp and myHRP then
                        myHRP.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
                    end
                    break
                end
            end
        end
    end,
})

local Section = Tab:CreateSection("Spectate Target")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local query = ""
local spectating = false
local spectateConn

local thirdPersonDistance = 8
local thirdPersonHeight = 2

local function GetPlayerByQuery(q)
    if not q or q == "" then return nil end
    q = q:lower()
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then
            local n = (pl.Name or ""):lower()
            local d = (pl.DisplayName or ""):lower()
            if n:match("^" .. q) or d:match("^" .. q) then
                return pl
            end
        end
    end
    return nil
end

local function getThirdPersonCFrame(rootCFrame, lookAtPos, distance, height)
    distance = distance or thirdPersonDistance
    height = height or thirdPersonHeight
    local backPos = rootCFrame.Position - rootCFrame.LookVector * distance + Vector3.new(0, height, 0)
    return CFrame.new(backPos, lookAtPos)
end

local function StartSpectate(target)
    if not target or not target.Parent then return end
    local char = target.Character
    if not char or not char.Parent then return end

    if spectateConn then spectateConn:Disconnect() spectateConn = nil end
    spectating = true

    spectateConn = RunService.RenderStepped:Connect(function()
        if not spectating then return end
        if not target or not target.Parent then
            spectating = false
            return
        end

        char = target.Character
        if not char then spectating = false return end

        local head = char:FindFirstChild("Head")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local lookAtPos = head and head.Position or (hrp and (hrp.Position + Vector3.new(0, 1.5, 0)) or nil)
        local rootCFrame = hrp and hrp.CFrame or (head and head.CFrame or nil)

        if lookAtPos and rootCFrame then
            local camCFrame = getThirdPersonCFrame(rootCFrame, lookAtPos, thirdPersonDistance, thirdPersonHeight)
            Camera.CameraType = Enum.CameraType.Scriptable
            Camera.CFrame = camCFrame
        else
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                Camera.CameraType = Enum.CameraType.Custom
                Camera.CameraSubject = humanoid
            end
        end
    end)
end

local function StopSpectate()
    spectating = false
    if spectateConn then spectateConn:Disconnect() spectateConn = nil end
    local myChar = LocalPlayer.Character
    local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if myHumanoid then
        Camera.CameraType = Enum.CameraType.Custom
        Camera.CameraSubject = myHumanoid
    else
        Camera.CameraType = Enum.CameraType.Custom
    end
end

Tab:CreateInput({
    Name = "・Spectate Player",
    PlaceholderText = "Nom ou DisplayName...",
    Flag = "SpectateInput",
    Callback = function(text)
        query = tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
    end,
})

Tab:CreateButton({
    Name = "・Confirmer Spectate",
    Callback = function()
        if spectating then StopSpectate() end
        local target = GetPlayerByQuery(query)
        if target then
            StartSpectate(target)
        end
    end,
})

Tab:CreateButton({
    Name = "・Stop Spectate",
    Callback = function()
        StopSpectate()
    end,
})

local Tab = Window:CreateTab("・Téléportation・", "footprints")
local Section = Tab:CreateSection("--- Téléportation ---")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

Tab:CreateButton({
	Name = "・TP Spawn",
	Callback = function()
		local targetPosition = Vector3.new(-486.8499755859375, 409.2698974609375, 120.93710327148438)
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
		end
	end,
})

Tab:CreateButton({
	Name = "・TP Zone Carcéral",
	Callback = function()
		local targetPosition = Vector3.new(-106.05229187011719, 4.764719486236572, 368.3371276855469)
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
		end
	end,
})

Tab:CreateButton({
	Name = "・TP Quartier Administratif",
	Callback = function()
		local targetPosition = Vector3.new(-213.84552001953125, 4.581797122955322, 119.62350463867188)
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
		end
	end,
})

Tab:CreateButton({
	Name = "・TP Quartier Sécuritaire",
	Callback = function()
		local targetPosition = Vector3.new(-528.648193359375, 4.740275859832764, 261.26727294921875)
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
		end
	end,
})

Tab:CreateButton({
	Name = "・TP Quartier Scientifique",
	Callback = function()
		local targetPosition = Vector3.new(-478.7444152832031, 28.462312698364258, 94.9267807006836)
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
		end
	end,
})

Tab:CreateButton({
	Name = "・TP Quartier Médical",
	Callback = function()
		local targetPosition = Vector3.new(54.863224029541016, 9.543076515197754, 49.651092529296875)
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
		end
	end,
})

Tab:CreateButton({
	Name = "・TP Quartier Inginérie Tech",
	Callback = function()
		local targetPosition = Vector3.new(-182.465087890625, -5.481750965118408, -186.7217559814453)
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
		end
	end,
})

local Section = Tab:CreateSection("")

Tab:CreateButton({
	Name = "・TP Gate-Alpha",
	Callback = function()
		local targetPosition = Vector3.new(-455.7083740234375, 4.7444682121276855, 589.7092895507812)
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
		end
	end,
})

Tab:CreateButton({
	Name = "・TP Base FIM",
	Callback = function()
		local targetPosition = Vector3.new(-2391.9716796875, 7.857818126678467, 3040.463134765625)
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
		end
	end,
})

Tab:CreateButton({
	Name = "・TP Base OL (Pas Sûr)",
	Callback = function()
		local targetPosition = Vector3.new(-420.51153564453125, -0.8816649317741394, 2889.084228515625)
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
		end
	end,
})

Tab:CreateButton({
	Name = "・TP Base IC",
	Callback = function()
		local targetPosition = Vector3.new(-2144.10986328125, 107.76148986816406, 1221.08056640625)
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
		end
	end,
})

local Tab = Window:CreateTab("・Give Armes・", "package-plus")
local Section = Tab:CreateSection("--- Give Armes ---")

local Paragraph = Tab:CreateParagraph({Title = "Lis ça", Content = "Méthode: Backpack To Backpack si tu reçois pas l'arme c'est que personne l'a dans son inventaire donc stresse pas et oui tu peux mettre les dégâts."})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function steal(toolName)
	local backpack = LocalPlayer:WaitForChild("Backpack")
	local existing = backpack:FindFirstChild(toolName)
	if existing then
		existing:Destroy()
	end
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local otherBackpack = player:FindFirstChild("Backpack")
			if otherBackpack then
				local tool = otherBackpack:FindFirstChild(toolName)
				if tool and tool:IsA("Tool") then
					tool.Parent = backpack
					break
				end
			end
			local char = player.Character
			if char then
				local tool = char:FindFirstChild(toolName)
				if tool and tool:IsA("Tool") then
					tool.Parent = backpack
					break
				end
			end
		end
	end
end

local toolNames = {
	"AKM", "Desert Eagle", "Glock-17", "Glock-19", "HK USP .45", "HK416", "HK416 Mod", "HK416A5", "HK416C",
	"Handcuffs", "IA2", "IA2 MOD", "INSM870", "Imbel 5.56 IA2", "Juggernaut Shield", "L85A2", "LWRC SMG .45",
	"M110", "M110 SASS", "M249 COMP", "M249 Para", "M2HH", "M38 SDMR", "M4 Carbine", "M4A0S", "M4A1",
	"M4A1 ACOG", "M4A1 URGI", "M4A1/ ACOG & M203", "M4A1/ M203", "M60", "M72 LAW", "M82A1", "M870", "M9",
	"MK18", "MK18 EO", "MK23 SOCOM", "MP5", "MP5A3", "MP5V2", "MP7", "MP9", "Matraque", "Medkit", "Menotte",
	"Mic", "Micro UZI", "Mortier", "Multiple'rapid'", "Noveske 10.5", "P2000", "P226", "P870", "Pizza",
	"RPK", "Remington 870", "Renetti", "SCAR-L", "SCAR-L Mod", "SIG MCX", "SLR36C", "SPAMARSTRIKE",
	"STI 2011", "Sac", "Salute", "Shield Armé", "Tablette", "TTSX Benelli M2", "Torch", "UMP45", "UMP9",
	"USP", "UZI", "Warsport LVOA-C"
}

for _, name in ipairs(toolNames) do
	Tab:CreateButton({
		Name = "・Give " .. name,
		Callback = function()
			steal(name)
		end,
	})
end

local Tab = Window:CreateTab("・Dangerous・", "message-circle-warning")
local Section = Tab:CreateSection("--- Dangerous ---")

local TargetWeapon = nil

Tab:CreateInput({
   Name = "・Nom De L'arme",
   CurrentValue = "",
   PlaceholderText = "Ex: M4A1",
   RemoveTextAfterFocusLost = false,
   Flag = "ExplosiveToolInput",
   Callback = function(text)
      TargetWeapon = (text and text ~= "") and text or nil
   end,
})

Tab:CreateButton({
   Name = "・Activer Balles Explosives",
   Callback = function()
      if not TargetWeapon then return end

      local player = game.Players.LocalPlayer
      local tool = player.Backpack:FindFirstChild(TargetWeapon) or (player.Character and player.Character:FindFirstChild(TargetWeapon))
      if not tool or not tool:FindFirstChild("ACS_Modulo") then return end

      local settingsModule = tool:FindFirstChild("ACS_Modulo"):FindFirstChild("Variaveis"):FindFirstChild("Settings")
      local ammoValue = tool:FindFirstChild("ACS_Modulo"):FindFirstChild("Variaveis"):FindFirstChild("Ammo")

      if settingsModule and ammoValue then
         local config = require(settingsModule)
         config.ExplosiveHit = true
         ammoValue.Value = 100000000
      end
   end,
})

local Section = Tab:CreateSection("Place blocks")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Size = nil

Tab:CreateInput({
   Name = "・Taille Du Bloc (X Y Z)",
   CurrentValue = "",
   PlaceholderText = "Ex: 100 100 100",
   RemoveTextAfterFocusLost = false,
   Flag = "SizeInput",
   Callback = function(text)
      text = string.gsub(text, "[,;%-]", " ")
      local x, y, z = string.match(text, "(%S+)%s+(%S+)%s+(%S+)")
      if x and y and z then
         Size = Vector3.new(tonumber(x), tonumber(y), tonumber(z))
      else
         Size = nil
      end
   end,
})

Tab:CreateButton({
   Name = "・Placer Le Bloc",
   Callback = function()
      if not Size then return end

      local player = Players.LocalPlayer
      local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
      if not hrp then return end

      local Breach = ReplicatedStorage:WaitForChild("ACS_Engine"):WaitForChild("Event"):FindFirstChild("Breach")
      if not Breach then return end

      Breach:FireServer(
         3,
         {Fortified = {}, Destroyable = Workspace},
         CFrame.new(),
         CFrame.new(),
         {
            CFrame = hrp.CFrame,
            Size = Size
         }
      )
   end,
})

local Section = Tab:CreateSection("Utilities")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicatedStorage:WaitForChild("Intercome-RS"):WaitForChild("EnvoyezAnnonce")

local message = "Ton Message Ici"

Tab:CreateInput({
	Name = "・Annonce Intercom",
	PlaceholderText = "Tape ton message ici",
	RemoveTextAfterFocusLost = false,
	Flag = "IntercomInput",
	Callback = function(text)
		message = text
	end,
})

Tab:CreateButton({
	Name = "・Envoyer Annonce",
	Callback = function()
		pcall(function()
			Remote:FireServer("INTERCOME", message)
		end)
	end,
})

Tab:CreateButton({
	Name = "・SPAM Annonce",
	Callback = function()
		task.spawn(function()
			while task.wait(0.7) do
				pcall(function()
					Remote:FireServer("INTERCOME", message)
				end)
			end
		end)
	end,
})

local Tab = Window:CreateTab("・Read Me・", "book-check")
local Section = Tab:CreateSection("--- Read Me ---")

local Paragraph = Tab:CreateParagraph({Title = "Read Me", Content = "Ce Script à été fait par g9pw aucun autre dev n'y a contribuer, merci de ne pas le partager sans mon accord. Rejoins mon discord pour plus d'infos."})

local Button = Tab:CreateButton({
    Name = "・Copy Discord Link",
    Callback = function()
        setclipboard("https://discord.gg/NnqntppsZa")

        Rayfield:Notify({
            Title = "Discord Link Copied",
            Content = "Paste In Your Browser",
            Duration = 6.5,
            Image = "badge-check", -- Img
        })
    end,
})