while wait(0.1) do
local playertable = game:GetService("Players"):GetPlayers()
for n,v in pairs(playertable) do
local length = 20

local usenums = true
local usespecial = true
local letters = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}
local nums = {"1","2","3","4","5","6","7","8","9","0"}
local special = {"!","@","#","$"} -- defining all characters in different tables


-- applying settings --
if usenums then
	for _,v in pairs(nums) do
		table.insert(letters,#letters+1,v) -- we only use table letters, so we add it to that table
	end
end

if usespecial then
	for _,v in pairs(special) do
		table.insert(letters,#letters+1,v) -- do the same here but for specials
	end
end

local str = ""
	math.randomseed(os.time())
for i=1,length do 
		str = str..letters[math.random(1,#letters)]
	end
		v.DisplayName = (str)
		v.Name = (str)
	end
end
--
