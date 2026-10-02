--// esp by nightzuu \\
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local function Create(class, parent, props, children)
    local obj = Instance.new(class)
    
    if typeof(parent) == "Instance" then
        obj.Parent = parent
    elseif typeof(parent) == "table" then
        props, children = parent, props
    end

    if props then
        for k, v in pairs(props) do
            obj[k] = v
        end
    end

    if children then
        for _, child in pairs(children) do
            child.Parent = obj
        end
    end

    return obj
end

local ESP = {}

local active = {}
local Connection = nil

local function updcontiune()
    if Connection then return end

    Connection = RunService.Heartbeat:Connect(function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local cam = workspace.CurrentCamera

        for i = #active, 1, -1 do
            local self = active[i]

            if not self.Target or not self.Target.Parent then
                self:Destroy()
                table.remove(active, i)
                continue
            end

            local pos = self.Target:GetPivot().Position
            local color = self.Color

            if self.Rainbow then
                color = Color3.fromHSV((tick() % 5) / 5, 1, 1)
            end

            self.Gradient.Rotation = (self.Gradient.Rotation + 1.5) % 360
            self.Gradient.Color = ColorSequence.new(color, Color3.new(1, 1, 1))

            if self.ShowDistance and root then
                local dist = math.floor((root.Position - pos).Magnitude)
                self.TextLabel.Text = self.Title .. "\n(" .. dist .. "m)"
            else
                self.TextLabel.Text = self.Title
            end

            self.TextLabel.TextColor3 = color
            self.Highlight.FillColor = color
            self.Highlight.OutlineColor = color

            if self.Line then
                local screenPos, onScreen = cam:WorldToViewportPoint(pos)
                self.Line.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                self.Line.To = Vector2.new(screenPos.X, screenPos.Y)
                self.Line.Color = color
                self.Line.Visible = onScreen
            end
        end

        if #active == 0 then
            Connection:Disconnect()
            Connection = nil
        end
    end)
end

function ESP:NewESP(args)
    local self = setmetatable({}, ESP)

    local Target = args.Target or args.Child
    if not Target then return end

    self.Target = Target
    self.Title = args.Title or args.Name or Target.Name
    self.TextSize = args.TextSize or 14
    self.Color = args.Color or Color3.fromRGB(0, 255, 25)
    self.Put = args.Put or "esp by nightzuu"
    self.ShowDistance = args.Distance or false
    self.Rainbow = args.Rainbow or false
    self.Tracer = args.Tracer or false
    self.MaxDistance = args.MaxDistance or 2000

    self.Gradient = Create("UIGradient", nil, {
        Color = ColorSequence.new(Color3.new(1,1,1), self.Color, Color3.new(0,0,0)),
        Rotation = 0
    })

    self.Billboard = Create("BillboardGui", CoreGui, {
        Name = self.Put,
        AlwaysOnTop = true,
        Size = UDim2.fromOffset(400, 100),
        StudsOffset = Vector3.new(0, 2, 0),
        Adornee = Target,
        MaxDistance = self.MaxDistance
    })

    self.TextLabel = Create("TextLabel", self.Billboard, {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = self.Title,
        TextSize = self.TextSize,
        TextColor3 = self.Color,
        FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Bold),
        TextStrokeTransparency = 1
    }, {
        Create("UIStroke", nil, {
            Thickness = 1,
            Color = Color3.new(0, 0, 0)
        }, {
            self.Gradient
        })
    })

    self.Highlight = Create("Highlight", CoreGui, {
        Adornee = Target,
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
        FillColor = self.Color,
        OutlineColor = self.Color,
        FillTransparency = 0.85,
        OutlineTransparency = 0
    })

    if self.Tracer and Drawing then
        self.Line = Drawing.new("Line")
        self.Line.Thickness = 1
        self.Line.Transparency = 1
        self.Line.Color = self.Color
        self.Line.Visible = false
    end

    table.insert(active, self)
    updcontiune()

    return self
end

function ESP:Destroy()
    if self.Line then
        self.Line:Remove()
        self.Line = nil
    end
    if self.Billboard then
        self.Billboard:Destroy()
        self.Billboard = nil
    end
    if self.Highlight then
        self.Highlight:Destroy()
        self.Highlight = nil
    end
end

return ESP
