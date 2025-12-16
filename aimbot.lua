-- // CONFIG \\ --
_G.Config = {
    ["Aimbot"] = {
        ["Enabled"] = false,
        ["Keybind"] = "Q",
        ["FOV"] = 80
    },
    ["Panic"] = {
        ["Enabled"] = true,
        ["Keybind"] = "M"
    }
};

-- // VARIABLES \\ --
_G.Variables = {
    ["Players"] = game:GetService("Players"),
    ["Run_Service"] = game:GetService("RunService"),
    ["User_Input_Service"] = game:GetService("UserInputService"),

    ["Player"] = game:GetService("Players").LocalPlayer,

    ["Mouse"] = game:GetService("Players").LocalPlayer:GetMouse(),
    ["Camera"] = workspace.CurrentCamera,

    ["Aimbot_Toggled"] = false,
    ["Aimbot_Target"] = nil
};

_G.Signals = {};

-- // FUNCTIONS \\ --
_G.Functions = {};

function _G.Functions.FOV_Search()
    local Target;
    local Distance = _G.Aimbot.FOV;

    for _, Player in _G.Variables.Players:GetPlayers() do
        if Player == _G.Variables.Player then continue end;
        if not Player.Character then continue end;

        local Player_Position, On_Screen = _G.Variables.Camera:WorldToScreenView(Player.Character.HumanoidRootPart.Position);
        Player_Position = Vector2.new(Player_Position.X, Player_Position.Y);
        local Mouse_Position = Vector2.new(_G.Variables.Mouse.X, _G.Variables.Mouse.Y);

        if On_Screen and (Player_Position - Mouse_Position).Magnitude <= Distance then
            Distance = (Player_Position - Mouse_Position).Magnitude;
            Target = Player.Character;
        end;
    end;

    return Target;
end;

function _G.Functions.Toggle_Aimbot()
    _G.Variables.Aimbot_Toggled = not _G.Variables.Aimbot_Toggled;
    _G.Variables.Target = nil;
end;

function _G.Functions.Aimbot_Main()
    if not _G.Config.Aimbot.Enabled then return end;
    if not _G.Variables.Aimbot_Toggled then return end;

    if not _G.Variables.Aimbot_Target then
        _G.Variables.Aimbot_Target = _G.Functions.FOV_Search();
    end;

    if _G.Variables.Aimbot_Target then
        _G.Variables.Camera.CFrame = CFrame.lookAt(_G.Variables.Camera.CFrame.Position, _G.Variables.Aimbot_Target.HumanoidRootPart.Position);
    end;
end;

function _G.Functions.Panic()
    task.defer(function()
        for _, Signal in Signals do
            Signal:Disconnect();
        end;

        _G.Signals = nil;
        _G.Config = nil;
        _G.Functions = nil;
        _G.Variables = nil;
    end);
end;

-- // RUN TIME \\ --
_G.Signals.Render_Stepped = _G.Variables.Run_Service.RenderStepped:Connect(function()
    task.spawn(_G.Functions.Aimbot_Main);
end);

_G.Signals.Input_Began = _G.Variables.User_Input_Service.InputBegan:Connect(function(Input, Processed)
    if Processed then return end;
    if not _G.Config then return end;

    if _G.Config.Aimbot.Enabled and Input.KeyCode == Enum.KeyCode[string.upper(_G.Config.Aimbot.Keybind)] then
        _G.Functions.Toggle_Aimbot();
        return;
    end;

    if _G.Config.Panic.Enabled and Input.KeyCode == Enum.KeyCode[string.upper(_G.Config.Panic.Keybind)] then
        _G.Functions.Panic();
        return;
    end;
end);