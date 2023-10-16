local Config = {
    WindowName = "Fade's General Exploit",
	Color = Color3.fromRGB(0,114,163),
	Keybind = Enum.KeyCode.RightShift
}


local time = 0
local players = game:GetService("Players")
local lPlayer = players.LocalPlayer
local numbr = 0
local Stats = game:GetService("Stats").PerformanceStats
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/FadeRemix/UI-Librarys/main/LOADSTRINGS/BracketV3%20Loadstring"))()
local Window = Library:CreateWindow(Config, game:GetService("CoreGui"))
local Char = lPlayer.Character
local humnoid = Char.Humanoid
local speaker = game.Players.LocalPlayer
local name = lPlayer.Name
local LPR = game:GetService("Workspace"):FindFirstChild(name)
gPlayers = players:GetPlayers()

local Tab1 = Window:CreateTab("General")
--local Tab2 = Window:CreateTab("Players")
local Tab3 = Window:CreateTab("UI Settings")

local Section1 = Tab1:CreateSection("Player")
local Misc = Tab1:CreateSection("Misc")
local Pref = Tab1:CreateSection("Performance")
local selff = Tab1:CreateSection("Info")
--local Sele = Tab2:CreateSection("Select A Player")
--local plrsetting = Tab2:CreateSection("About The Player")
local Section3 = Tab3:CreateSection("Menu")
local Section4 = Tab3:CreateSection("Background")


-------------- Get Players Func
--[[
local function GrabPlayers()

local var2 = {}

for i,v in pairs(gPlayers) do
   table.insert(var2,v.Name)
	end
return var2
end
]]
------------ Chat Spam Function
--[[
local function spamz(Word)
	game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Word,"All")
end
]]
------------ Rounding Function

local function round(number, decimalPlaces)
	return math.round(number * 10^decimalPlaces) * 10^-decimalPlaces
end
 

---------------- Walkspeed

local Slider1 = Section1:CreateSlider("Walkspeed", 0,100,nil,true, function(Value)
	humnoid.WalkSpeed = (Value)
end)
Slider1:AddToolTip("Adjusts your walkspeed")
Slider1:SetValue(16)

local ButtonWALK = Section1:CreateButton("Reset Walk Speed", function()
	Slider1:SetValue(16)
end)
ButtonWALK:AddToolTip("Will reset walk speed")

------------------ Jump Height

local Slider2 = Section1:CreateSlider("Jump Height", 0,500,nil,true, function(Value)
	humnoid.JumpPower = (Value)
	--print(Value)
end)
Slider2:AddToolTip("Adjusts your jump height")
Slider2:SetValue(50)

local ButtonJUMP = Section1:CreateButton("Reset Jump Height", function()
	Slider2:SetValue(50)
end)
ButtonJUMP:AddToolTip("Will reset jump height")

---------------- Hip Heigt

local Slider3 = Section1:CreateSlider("Hip Height", 0,100,nil,true, function(Value)
	humnoid.HipHeight = (Value)
end)
Slider3:AddToolTip("Adjusts your hip height")
Slider3:SetValue(2)

local ButtonHIP = Section1:CreateButton("Reset Hip Height", function()
  Slider3:SetValue(2)
end)
ButtonHIP:AddToolTip("Will reset hip height")

---------------- Suicide

local Button1 = Section1:CreateButton("Suicide", function()
		humnoid.Health = 0
		print("dead")
end)
Button1:AddToolTip("Kills your player")

---------------- Message Chat
--------PLAN TO ADD SPAMMER HERE (CANT BE BOTHERD TO MAKE RN)
--[[
local TextToSpam = Misc:CreateTextBox("Say Something", "Enter Text", false, function(Value)
	spamz((Value))
end)
TextToSpam:AddToolTip("Input text to spam")
]]
---------------- Set Name 

local TextBox1 = Misc:CreateTextBox("Name Changer*", "Enter New Name", false, function(Value)
	lPlayer.Name = (Value)
end)
TextBox1:AddToolTip("Will Change Current Name (Will Conflict With Name Scramble)")

local TextBox2 = Misc:CreateTextBox("Display Name Changer*", "Enter New Display Name", false, function(POGCHAMP)
	lPlayer.DisplayName = (POGCHAMP)
end)
TextBox2:AddToolTip("Will Change Current Display Name (Will Conflict With Name Scramble)")

---------------- Name Scrambler

local Button2 = Misc:CreateButton("Name Scrambler", function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/FadeRemix/GEv1/main/GE-NameScramble.lua"))()
end)
Button2:AddToolTip("Will make all player names random (Can't Undo)")

---------------- No clip

local NoclipToggle = Misc:CreateToggle("No-clip", nil, function(State)
	local Noclipping = nil
if State == true then
		Clip = false
	wait(0.1)
	local function NoclipLoop()
		if Clip == false and speaker.Character ~= nil then
			for _, child in pairs(speaker.Character:GetDescendants()) do
				if child:IsA("BasePart") and child.CanCollide == true and child.Name ~= floatName then
					child.CanCollide = false
				end
			end
		end
	end
	Noclipping = game:GetService('RunService').Stepped:Connect(NoclipLoop)
	elseif State == false then
			if Noclipping then
		Noclipping:Disconnect()
	end
	Clip = true
end
end)
NoclipToggle:AddToolTip("Allows you to walk in any room")
NoclipToggle:CreateKeybind("E", function(Key)
	print(Key)
end)

---------------- Force Sit

local Toggle1 = Misc:CreateToggle("Force Sit", nil, function(State)
	if State == true then
		lPlayer.Character.Humanoid.Sit = true
			elseif State == false then
			lPlayer.Character.Humanoid.Sit = false
		print("unsit")
	end
end)
Toggle1:AddToolTip("Will force your player to sit")
Toggle1:CreateKeybind("Y", function(Key)
	print(Key)
end)

------------ Players

local plrslabel = selff:CreateLabel("hi :)")

------------ Player Name

local Label2 = selff:CreateLabel("Display Name: "..lPlayer.DisplayName)
local Label1 = selff:CreateLabel("Name: "..lPlayer.Name)

------------ Health 

local healthlabel = selff:CreateLabel("Health: "..humnoid.Health)

------------ Team Name

local teamlabel = selff:CreateLabel("hi :)")


------------ Player Select
--[[
local PlrNameLBL = plrsetting:CreateLabel("pog")
local PlrSelectDROP = Sele:CreateDropdown("Players", GrabPlayers(), function(String)

	PlrNameLBL:UpdateText("Name: "..String)
end)
PlrSelectDROP:AddToolTip("Players")
]]
------------ Extra UI stuff

--[[
local Toggle1 = Section1:CreateToggle("Toggle 1", nil, function(State)
	print(State)
end)
Toggle1:AddToolTip("Toggle 1 ToolTip")
Toggle1:CreateKeybind("Y", function(Key)
	print(Key)
end)
local TextBox1 = Section1:CreateTextBox("TextBox 1", "Only numbers", true, function(Value)
	print(Value)
end)
TextBox1:AddToolTip("Yes only numbers")
--TextBox1:SetValue("new value here")
Section1:CreateTextBox("TextBox 1\nMultiline", "numbers and letters", false, function(String)
	print(String)
end)
-------------
local Dropdown1 = Section1:CreateDropdown("Dropdown 1", {"Option 1","Option 2","Option 3"}, function(String)
	print(String)
end)
Dropdown1:AddToolTip("Dropdown 1 ToolTip")
Dropdown1:SetOption("Option 1")
-------------
local Colorpicker1 = Section1:CreateColorpicker("Colorpicker 1", function(Color)
	print(Color)
end)
Colorpicker1:AddToolTip("Colorpicker 1 ToolTip")
Colorpicker1:UpdateColor(Color3.fromRGB(255,0,0))
-------------
Section2:CreateLabel("Label 2\nMultiline")
-------------
local Button2 = Section2:CreateButton("Button 2\nMultiline", function()
	print("Click Button 2")
end)
Button2:AddToolTip("Button 2 ToolTip\nMultiline")
-------------
local Toggle2 = Section2:CreateToggle("Toggle 2\nMultiline", nil, function(State)
	print(State)
end)
Toggle2:AddToolTip("Toggle 2 ToolTip\nMultiline")
Toggle2:CreateKeybind("U", function(Key)
	print(Key)
end)
-------------
local Slider2 = Section2:CreateSlider("Slider 2\nMultiline", 0,100,nil,false, function(Value)
	print(Value)
end)
Slider2:AddToolTip("Slider 2 ToolTip\nMultiline")
Slider2:SetValue(25)
-------------
local Dropdown2 = Section2:CreateDropdown("Dropdown 2\nMultiline", {"Option 4","Option 5","Option 6"}, function(String)
	print(String)
end)
Dropdown2:AddToolTip("Dropdown 2 ToolTip")
Dropdown2:SetOption("Option 6")
-------------
local Colorpicker2 = Section2:CreateColorpicker("Colorpicker 2\nMultiline", function(Color)
	print(Color)
end)
Colorpicker2:AddToolTip("Colorpicker 2 ToolTip")
Colorpicker2:UpdateColor(Color3.fromRGB(0,0,255))
]]
-------------

local Toggle3 = Section3:CreateToggle("UI Toggle", nil, function(State)
	Window:Toggle(State)
end)
Toggle3:CreateKeybind(tostring(Config.Keybind):gsub("Enum.KeyCode.", ""), function(Key)
	Config.Keybind = Enum.KeyCode[Key]
end)
Toggle3:SetState(true)

local Colorpicker3 = Section3:CreateColorpicker("UI Color", function(Color)
	Window:ChangeColor(Color)
end)
Colorpicker3:UpdateColor(Config.Color)

-- credits to jan for patterns

local Dropdown3 = Section4:CreateDropdown("Image", {"Default","Hearts","Abstract","Hexagon","Circles","Lace With Flowers","Floral"}, function(Name)
	if Name == "Default" then
		Window:SetBackground("2151741365")
	elseif Name == "Hearts" then
		Window:SetBackground("6073763717")
	elseif Name == "Abstract" then
		Window:SetBackground("6073743871")
	elseif Name == "Hexagon" then
		Window:SetBackground("6073628839")
	elseif Name == "Circles" then
		Window:SetBackground("6071579801")
	elseif Name == "Lace With Flowers" then
		Window:SetBackground("6071575925")
	elseif Name == "Floral" then
		Window:SetBackground("5553946656")
	end
end)
Dropdown3:SetOption("Default")

local Colorpicker4 = Section4:CreateColorpicker("Color", function(Color)
	Window:SetBackgroundColor(Color)
end)
Colorpicker4:UpdateColor(Color3.new(1,1,1))

local Slider3 = Section4:CreateSlider("Transparency",0,1,nil,false, function(Value)
	Window:SetBackgroundTransparency(Value)
end)
Slider3:SetValue(0)

local Slider4 = Section4:CreateSlider("Tile Scale",0,1,nil,false, function(Value)
	Window:SetTileScale(Value)
end)
Slider4:SetValue(0.5)

------------ Stat Labels
local i = 0
local labelCPU = Pref:CreateLabel("hi :)")
local labelGPU = Pref:CreateLabel("hi :)")
local labelMEM = Pref:CreateLabel("hi :)")
--local labelPLR = Pref:CreateLabel("Players")
local labelTIME = Pref:CreateLabel("Time Elapsed: 00:00:00")




while wait(0.1) do
	i = i + 1
	local humnoid2 = game:GetService("Workspace"):FindFirstChild(name).Humanoid
	local GPUVAL = Stats["GPU"]:GetValue()
		labelGPU:UpdateText("GPU: "..round(GPUVAL,3))
	local CPUVAL = Stats["CPU"]:GetValue()
		labelCPU:UpdateText("CPU: "..round(CPUVAL,3))
	local MEMUsage = Stats["Memory"]:GetValue()
		labelMEM:UpdateText("Memory: "..round(MEMUsage,3))
	--local playertable = game:GetService("Players"):GetPlayers()
		--labelPLR:UpdateText("Players in server: "..#playertable)
	healthlabel:UpdateText("Health: "..humnoid2.Health)
if not lPlayer.Team then
	teamlabel:UpdateText("Team: None")
else
	teamlabel:UpdateText("Team: "..lPlayer.Team.Name)
end
Label1:UpdateText("Name: "..lPlayer.Name)
Label2:UpdateText("Display Name: "..lPlayer.DisplayName)
local numOFplrs = #gPlayers
	plrslabel:UpdateText("Players in Game: "..numOFplrs)
	if i == 10 then
		time = time + 1
  	labelTIME:UpdateText(string.format("Time Elapsed: ".."%02d:%02d:%02d",time/3600,(time%3600)/60,time%60))
  	i = 0
  end
end
-- HAD TO PUSH A COMMIT
