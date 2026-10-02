local esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuckyEvaletion/ESP/refs/heads/main/ESP.lua"))()

for _, v in ipairs(game.Players:GetPlayers()) do
    if v ~= game.Players.LocalPlayer and v.Character then
        esp:NewESP({
            Target = v.Character,
            Name = v.Name,
            Color = Color3.fromRGB(255,0,0),
            Distance = true,
            Rainbow = true,
            Tracer = true,
        })
    end
end
