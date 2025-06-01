local library = loadstring(
    game:HttpGet(
        'https://raw.githubusercontent.com/lolpoppyus/Roblox-Lua/master/Pop%20UI%20Lib',
        true
    )
)()

local ui = library:Tab('Tab')

local Folder = ui:Folder('Folder')

ui:Button('Button', function()
    print('yes')
end)

ui:Toggle('Toggle', function(arg)
    print(arg)
end)

ui:Slider('Slider', 0, 100, function(arg) end)

ui:Textbox('Textbox', function(arg)
    pcall(function() end)
end)

ui:Dropdown('Dropdown', { 'Yes', 'No', 'IDK' }, function(arg)
    if arg == 'Yes' then
        print('Yes')
    elseif arg == 'No' then
        print('No')
    end
end)

local update = ui:Dropdown('REF Drop', {}, function(arg)
    local plr = Players.LocalPlayer.Character.HumanoidRootPart
    local target = Players[arg].Character.HumanoidRootPart
    plr.CFrame = target.CFrame
    print('Teleported to: ' .. tostring(arg))
end)

local update2 = Folder:Dropdown('Drop', {}, function(arg)
    local plr = Players.LocalPlayer.Character.HumanoidRootPart
    local target = Players[arg].Character.HumanoidRootPart
    plr.CFrame = target.CFrame
    print('Teleported to: ' .. tostring(arg))
end)

Folder:Colorpicker('Color', function(arg)
    print(arg)
end)

ui:Textstring('Discord', 'wcyT7Ms')

ui:Textstring2('Created by - Poppyus')

ui:Textbox2('Teleport', 'Player', function(arg)
    pcall(function()
        local plr = Players.LocalPlayer.Character.HumanoidRootPart
        local target = Players[arg].Character.HumanoidRootPart
        plr.CFrame = target.CFrame
    end)

    print('Teleported to: ' .. tostring(arg))
end)

while wait(1) do
    local players = game.Players:GetChildren()
    local array = {}

    for i, v in pairs(players) do
        table.insert(array, v.Name)
    end

    update(array)
end
