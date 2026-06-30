-- // base
local base = "https://raw.githubusercontent.com/hvhstarrr1337-art/evolution-utils/main/"
-- // library
local library = loadstring(game:HttpGet(base.."library.lua?v="..tostring(math.random(1, 1000000))))()
-- // icons
if not isfolder("evolution-utils") then
	makefolder("evolution-utils")
end
local function icon(name)
	local file = "evolution-utils/"..name..".png"
	if not isfile(file) then
		writefile(file, game:HttpGet(base..name..".png"))
	end
	return getcustomasset(file)
end
-- // window
local window = library:new({
	name = "evolution.wtf | test",
	accent = Color3.fromRGB(225, 58, 81),
	unload = function()
		library.unload()
	end
})
-- // pages
local page1 = window:page({name = "Test1", icon = icon("crosshair")})
local page2 = window:page({name = "Test2", icon = icon("eye")})
-- // page1 with subtabs
local sub1 = page1:subtab({name = "Sub1"})
local sub2 = page1:subtab({name = "Sub2"})
--
local s1 = sub1:section({name = "Test1", side = "left", size = 200})
s1:toggle({name = "Toggle1", callback = function(state) end})
s1:slider({name = "Slider1", min = 0, max = 100, def = 50, callback = function(value) end})
s1:dropdown({name = "Dropdown1", options = {"Option1", "Option2", "Option3"}, def = "Option1", callback = function(option) end})
--
local s2 = sub1:section({name = "Test2", side = "right", size = 200})
s2:button({name = "Button1", callback = function() end})
s2:keybind({name = "Keybind1", def = Enum.KeyCode.E, mode = "toggle", callback = function(state)
	print("keybind1 state:", state)
end})
--
local s3 = sub2:section({name = "Test3", side = "left", size = 150})
s3:toggle({name = "Toggle2", callback = function(state) end})
s3:colorpicker({name = "Color1", def = Color3.fromRGB(255, 255, 255), callback = function(color) end})
-- // page2 normal sections
local s4 = page2:section({name = "Test4", side = "left", size = 150})
s4:toggle({name = "Toggle3", callback = function(state) end})
s4:slider({name = "Slider2", min = 0, max = 360, def = 90, callback = function(value) end})
--
local s5 = page2:section({name = "Test5", side = "right", size = 150})
s5:button({name = "Button2", callback = function() end})
s5:multibox({name = "Multibox1", options = {"A", "B", "C"}, callback = function(options) end})
-- // built-in config tab
window:configtab({name = "Configs", icon = icon("save"), folder = "evolution_test"})
-- // open default
page1:openpage()
