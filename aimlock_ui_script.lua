-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInput = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera

-- UI SETUP
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ui = Instance.new("ScreenGui", PlayerGui)
ui.Name = "AimlockUI"
ui.ResetOnSpawn = false

local button = Instance.new("TextButton", ui)
button.Size = UDim2.new(0, 120, 0, 40)
button.Position = UDim2.new(0.5, -60, 0.9, 0)
button.Text = "AIMLOCK"
button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 20
button.BorderSizePixel = 0
button.AnchorPoint = Vector2.new(0.5, 0.5)

-- GET NEAREST HUMANOID
local function getNearestTarget()
    local closest = nil
    local shortest = math.huge
    local myHRP = Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= Character and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            local dist = (myHRP.Position - obj.HumanoidRootPart.Position).Magnitude
            if dist < shortest then
                shortest = dist
                closest = obj
            end
        end
    end
    return closest
end

-- FACE FULL (X and Y)
local function faceFully(rootPart, lookAt)
    rootPart.CFrame = CFrame.new(rootPart.Position, lookAt)
end

-- MAIN AIMLOCK FUNCTION
local function aimlock()
    local target = getNearestTarget()
    if not target then return end

    local tHRP = target:FindFirstChild("HumanoidRootPart")
    local head = target:FindFirstChild("Head")
    local myHRP = Character:FindFirstChild("HumanoidRootPart")
    if not tHRP or not myHRP or not head then return end

    -- Press Q
    VirtualInput:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    task.wait(0.05)
    VirtualInput:SendKeyEvent(false, Enum.KeyCode.Q, false, game)

    -- Teleport 5 studs above target (changed from 4 to 5)
    local abovePos = tHRP.Position + Vector3.new(0, 5, 0)
    myHRP.CFrame = CFrame.new(abovePos)

    -- Stay above for 0.2 seconds
    task.wait(0.2)

    -- Drop down to 2 studs above (so you're now closer)
    local dropPos = tHRP.Position + Vector3.new(0, 2, 0)
    myHRP.CFrame = CFrame.new(dropPos)

    -- Lock onto head for 2 seconds
    local start = tick()
    while tick() - start < 2 do
        faceFully(myHRP, head.Position)
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, head.Position)
        RunService.Heartbeat:Wait()
    end
end

-- BIND TO UI
button.MouseButton1Click:Connect(aimlock)
