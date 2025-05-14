--CONSTANTS
repeat task.wait() until game:IsLoaded()
local notifModule = require(game:GetService("ReplicatedStorage").Modules.Notification)
notifModule.CreateNotification(false, "Rinn Hub Executed")
local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()
local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanRoot = character:WaitForChild("HumanoidRootPart")
local farms = workspace:WaitForChild("Farm")
local sellPart = workspace.Tutorial_Points.Tutorial_Point_2
local backPack = player.Backpack
local human = character:WaitForChild("Humanoid")
local remote = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents")
local BuyMultiplier = 10
--GIFTING PLAYERS VARIABLE
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local TutorialPart = workspace.Tutorial_Points.Tutorial_Point_2

--GLOBAL ENVS
getgenv().WebhookWait = 0
getgenv().WebhookToggle = false
getgenv().WebhookURL = nil
getgenv().WebhookID = 0
getgenv().isHarvest = false
getgenv().isFavor = false
getgenv().isOffer = false
getgenv().isSell = false
getgenv().isBuyFruit = false
getgenv().isBuyGear = false
getgenv().PlantSeeds = false
getgenv().PlaceEggs = false
getgenv().ClaimDaily = false
getgenv().AutoGift = false
getgenv().GiftPlayer = ""
getgenv().AutoAccept = false


--FORMAT NUMBERS
local function FormatNumbers(num)
    -- Split into whole and decimal parts
    local whole, decimal = math.modf(num)
    whole = tostring(math.floor(whole))
    
    -- Format the whole number part
    local formatted = ""
    local length = #whole
    
    for i = 1, length do
        formatted = formatted .. string.sub(whole, i, i)
        if (length - i) % 3 == 0 and i ~= length then
            formatted = formatted .. ","
        end
    end
    
    if decimal > 0 then
        decimal = string.sub(tostring(decimal), 3) -- Remove "0."
        formatted = formatted .. "." .. decimal
    end
    
    return formatted
end

-- UI Library
local Window = MacLib:Window({
	Title = "Rinn Hub",
	Subtitle = "Grow a Garden | Free Script",
	Size = UDim2.fromOffset(868, 650),
	DragStyle = 2,
	DisabledWindowControls = {},
	ShowUserInfo = true,
	Keybind = Enum.KeyCode.RightControl,
})
--TABS
local TabGroup = {
	TabGroup1 = Window:TabGroup()
}
local Tabs = {
    Main = TabGroup.TabGroup1:Tab({ Name = "Main", Image = "rbxassetid://18821914323" }),
    Gift = TabGroup.TabGroup1:Tab({ Name = "Gift", Image = "rbxassetid://18821914323" }),
    Webhook = TabGroup.TabGroup1:Tab({ Name = "Webhook", Image = "rbxassetid://18821914323" }),
	Misc = TabGroup.TabGroup1:Tab({ Name = "Misc", Image = "rbxassetid://10734950309" })
}
local Sections = {
   	MainSection1 = Tabs.Main:Section({ Side = "Left" }),
    MainSection2 = Tabs.Main:Section({ Side = "Right" }),
    MainSection3 = Tabs.Main:Section({ Side = "Left" }),
    MainSection4 = Tabs.Main:Section({ Side = "Right" }),
    MainSection5 = Tabs.Main:Section({ Side = "Right" }),
    WebhookSection1 = Tabs.Webhook:Section({ Side = "Left" }),
    GuiSection1 = Tabs.Misc:Section({ Side = "Left" }),
    GuiSection2 = Tabs.Misc:Section({ Side = "Left" }),
    GiftSection1 = Tabs.Gift:Section({ Side = "Left" }),
}

--MAIN SECTIONS
Sections.MainSection1:Header({
	Text = "Auto Farm",
}, "Main")

Sections.MainSection2:Header({
	Text = "Auto Buy",
}, "Main")
Sections.MainSection3:Header({
	Text = "Farm Status",
}, "Main")
Sections.MainSection4:Header({
	Text = "Plant Seeds",
}, "Main")
Sections.MainSection5:Header({
	Text = "Place Eggs",
}, "Main")




-- TABLES ##############################################################################
local PlayerList = game:GetService("Players")
local PlayerDropdown = {}

--Initialize
for _, v in pairs(PlayerList:GetChildren()) do
table.insert(PlayerDropdown, v.Name)
end
--REMOVE PROXIMITY CD 
local function RemoveHoldDuration()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            v.HoldDuration = 0
        end
    end
end
RemoveHoldDuration()
workspace.DescendantAdded:Connect(function(v)
    if v:IsA("ProximityPrompt") then
        v.HoldDuration = 0
    end
end)
--REMOVE RAGDOLL
humanRoot.CanCollide = false

local FruitBuy = {"Mango","Grape","Dragon Fruit","Durian","Pepper","Coconut","Cactus", "Cacao"}
local GearBuy = {"Basic Sprinkler","Master Sprinkler","Advanced Sprinkler","Godly Sprinkler"}
local SeedPlant = {"Mango","Grape","Dragon Fruit","Durian","Pepper","Coconut","Cactus", "Cacao"}
local PlaceEgg = {"Premium Night Egg", "Night Egg", "Mythical Egg", "Legendary Egg","Bug Egg","Divine Egg","Exotic Bug Egg"}
--GET SEED NAMES
local SeedFolder = game:GetService("ReplicatedStorage").Seed_Models
local fruitArray = {}
for _, fruit in pairs(SeedFolder:GetChildren()) do
    table.insert(fruitArray, fruit.Name)
end
--GET EGGS NAMES
local EggFolder = game:GetService("ReplicatedStorage").Assets.Models.EggModels
local Eggs = {}
for _, egg in pairs(EggFolder:GetChildren()) do
    table.insert(Eggs, egg.Name)
end

-- ##########################################################################################


--Auto Harvest
Sections.MainSection1:Toggle({
	Name = "Enable Farm",
	Callback = function(value)
        if value then
            getgenv().isHarvest = true
            task.spawn(function ()
                while getgenv().isHarvest do
                        --HARVEST
                        MacLib.Options["LiveStatus"]:UpdateHeader("✅ Status | Harvesting")
                        print("HARVESTING")
                        for _, farm in pairs(farms:GetDescendants()) do
                            if farm:IsA("Folder") and farm.Name == "Data" and farm:FindFirstChild("Owner") and farm.Owner.Value == player.Name then
                                local plants = farm.Parent:FindFirstChild("Plants_Physical")
                                if plants then
                                    for _, descendant in pairs(plants:GetDescendants()) do
                                        if descendant:IsA("ProximityPrompt") and descendant.Enabled then
                                            if #backPack:GetChildren() >= 200 then break end -- Stop if bag full
                                            local part = descendant.Parent
                                            if part and part:IsA("BasePart") then
                                                character:PivotTo(part.CFrame * CFrame.new(0, 0.5, 0))
                                                task.wait(0.1)
                                                fireproximityprompt(descendant)
                                                task.wait(0.1)
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        --PLANT
                        if getgenv().PlantSeeds then
                            print("PLANTING SEEDS")
                            for _, farm in pairs(farms:GetDescendants()) do
                            if farm:IsA("Folder") and farm.Name == "Data" and farm:FindFirstChild("Owner") and farm.Owner.Value == player.Name then
                                local plantPart = farm.Parent:FindFirstChild("Plant_Locations")
                                if plantPart then
                                   for _, part in pairs(plantPart:GetDescendants()) do
                                        for _, tool in pairs(backPack:GetChildren()) do
                                            if string.find(tool.Name, "Seed") then
                                                print("Planting:" .. tool.Name)
                                                local firstWord = string.gsub(tool.Name, " Seed.*", "")
                                                for _, v in pairs(SeedPlant) do
                                                    if v == firstWord then
                                                        MacLib.Options["LiveStatus"]:UpdateHeader("✅ Status | Planting: " .. firstWord)
                                                        human:EquipTool(tool)
                                                        -- PLANT 5X
                                                        for i = 1, 5 do
                                                        task.wait(0.1)
                                                        local x = part.CFrame.Position.X + math.random(-5, 5)
                                                        local z = part.CFrame.Position.Z + math.random(-5, 5)
                                                        remote:WaitForChild("Plant_RE"):FireServer(vector.create(x, 0, z), firstWord)
                                                        end
                                                        task.wait(0.1)
                                                        print("Planted: " .. firstWord)
                                                        human:UnequipTools()
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            end
                        end

                        --EGGS
                        if getgenv().PlaceEggs then
                            print("PLACING EGGS")
                            for _, farm in pairs(farms:GetDescendants()) do
                            if farm:IsA("Folder") and farm.Name == "Data" and farm:FindFirstChild("Owner") and farm.Owner.Value == player.Name then
                                local plantPart = farm.Parent:FindFirstChild("Plant_Locations")
                                if plantPart then
                                   for _, part in pairs(plantPart:GetDescendants()) do
                                        for _, tool in pairs(backPack:GetChildren()) do
                                           if string.find(tool.Name, "Egg") then
                                                for _, v in pairs(PlaceEgg) do
                                                    if string.find(tool.Name, v) then
                                                        human:EquipTool(tool)
                                                        -- PLACE 5X
                                                        for i = 1, 5 do
                                                        task.wait(0.1)
                                                        local x = part.CFrame.Position.X + math.random(-5, 5)
                                                        local z = part.CFrame.Position.Z + math.random(-5, 5)
                                                        remote:WaitForChild("PetEggService"):FireServer("CreateEgg", vector.create(x, 0, z))
                                                        end
                                                        task.wait(0.1)
                                                        print("Placed Egg: " .. tool.Name)
                                                        human:UnequipTools()
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    end
                                end
                            end
                        end

                            --AUTO GIFT
                        if getgenv().AutoGift then
                            MacLib.Options["LiveStatus"]:UpdateHeader("✅ Status | Gifting to: ".. getgenv().GiftPlayer)
                            local giftedFind = Players:FindFirstChild(getgenv().GiftPlayer)
                            local giftChar = giftedFind.Character or giftedFind.CharacterAdded:Wait()
                            local giftHumanPart = giftChar:FindFirstChild("HumanoidRootPart")
                            MacLib.Options["LiveStatus"]:UpdateHeader("✅ Status | Waiting for: ".. getgenv().GiftPlayer)
                            repeat task.wait() until ((giftHumanPart.Position - TutorialPart.Position).Magnitude) < 3
                            MacLib.Options["LiveStatus"]:UpdateHeader("✅ Status | Gifting to: ".. getgenv().GiftPlayer)
                             for _, tool in pairs(backPack:GetChildren()) do
                                if not getgenv().AutoGift then break end
                                if not (
                                    string.find(tool.Name, "Seed") or 
                                    string.find(tool.Name, " Egg") or 
                                    string.find(tool.Name, "Staff") or 
                                    string.find(tool.Name, "Age") or
                                    string.find(tool.Name, "Wrench") or
                                    string.find(tool.Name, "Trowel") or
                                    string.find(tool.Name, "Shovel") or
                                    string.find(tool.Name, "Watering Can") or
                                    string.find(tool.Name, "Lightning Rod") or
                                    string.find(tool.Name, "Sprinkler")
                                ) then
                                    print("Gifting: " .. tool.Name)
                                    if not getgenv().AutoGift then break end
                                    human:UnequipTools()
                                    MacLib.Options["LiveStatus"]:UpdateHeader("✅ Status | Waiting for: ".. getgenv().GiftPlayer)
                                    repeat task.wait() until ((giftHumanPart.Position - TutorialPart.Position).Magnitude) < 3
                                    MacLib.Options["LiveStatus"]:UpdateHeader("✅ Status | Gifting to: ".. getgenv().GiftPlayer)
                                    humanRoot.CFrame = giftHumanPart.CFrame
                                    human:EquipTool(tool)
                                    task.wait(0.1)
                                    local prompt = giftedFind.Character:FindFirstChildWhichIsA("ProximityPrompt", true)
                                    MacLib.Options["LiveStatus"]:UpdateHeader("✅ Status | Waiting for: ".. getgenv().GiftPlayer)
                                    repeat task.wait() until ((giftHumanPart.Position - TutorialPart.Position).Magnitude) < 3
                                    MacLib.Options["LiveStatus"]:UpdateHeader("✅ Status | Gifting to: ".. getgenv().GiftPlayer)
                                    if prompt then
                                        prompt:InputHoldBegin() 
                                        task.wait()
                                        prompt:InputHoldEnd()
                                    end
                                end
                            end
                        end

                        --AUTO ACCEPT
                        if getgenv().AutoAccept then
                            MacLib.Options["LiveStatus"]:UpdateHeader("✅ Status | Accepting Gifts")
                            local GiftNotifFrame = player.PlayerGui.Gift_Notification.Frame
                            local connection = {}
                            connection = GiftNotifFrame.ChildAdded:Connect(function (child)
                                    for _, d in pairs(child:GetDescendants()) do
                                    local a = d:FindFirstChild("Frame") and d.Frame:FindFirstChild("Accept")
                                    if a then print("Found Accept:", a) end
                                    replicatesignal(a.MouseButton1Click) 
                                end
                            end)
                        end

                        --FAVOR
                        if getgenv().isFavor then
                                MacLib.Options["LiveStatus"]:UpdateHeader("✅ Status | Checking for Moonlight Fruits")
                                task.wait(0.5)
                            	print("FAVORITE MOONLIGHT FRUITS")
                                for _, child in pairs(backPack:GetChildren()) do
                                if string.find(child.Name, "%[Moonlit%]") then
                                    print(child.Name)
                                    local args = {
                                        game:GetService("Players").LocalPlayer:WaitForChild("Backpack"):WaitForChild(child.Name)
                                    }
                                remote:WaitForChild("Favorite_Item"):FireServer(unpack(args))
                                end
                                end
                        end

                        --OFFER
                        if getgenv().isOffer then
                            MacLib.Options["LiveStatus"]:UpdateHeader("✅ Status | Offering Fruits")
                            task.wait(0.5)
                           print("OFFERING MOONLIGHT FRUITS")
                            remote:WaitForChild("NightQuestRemoteEvent"):FireServer("SubmitAllPlants")
                        end

                        --SELL
                        if getgenv().isSell then
                            MacLib.Options["LiveStatus"]:UpdateHeader("✅ Status | Selling Fruits")
                            task.wait(0.5)
                            print("MAXED INVENTORY | SELLING")
                            humanRoot.CFrame = sellPart.CFrame
                            task.wait(2)
                            remote:WaitForChild("Sell_Inventory"):FireServer()
                        end

                        --BUY FRUITS
                        if getgenv().isBuyFruit then
                            MacLib.Options["LiveStatus"]:UpdateHeader("✅ Status | Buying Fruits")
                            task.wait(0.5)
                            for i = 1,BuyMultiplier do -- BUY 10X
                            for _, buy in pairs(FruitBuy) do
                                remote:WaitForChild("BuySeedStock"):FireServer(buy)
                            end
                            end
                        end
                        --BUY GEAR
                        if getgenv().isBuyGear then
                            MacLib.Options["LiveStatus"]:UpdateHeader("✅ Status | Buying Gears")
                            task.wait(0.5)
                            print("BUYING GEARS")
                            for _, buy in pairs(GearBuy) do
                                remote:WaitForChild("BuyGearStock"):FireServer(buy)
                            end
                        end

                        --CLAIM DAILY
                        if getgenv().ClaimDaily then
                            MacLib.Options["LiveStatus"]:UpdateHeader("✅ Status | Claiming Daily")
                            game:GetService("ReplicatedStorage"):WaitForChild("ByteNetReliable"):FireServer(buffer.fromstring("\002"))
                        end

                        MacLib.Options["LiveStatus"]:UpdateHeader("⛔ Status | Waiting for cooldown")


                        --DEBUG UnequipTools
                        human:UnequipTools()

                        task.wait(10)
                end
            end)

        else
            getgenv().isHarvest = false
        end
	end,
}, "Enable Farm")
--PLANT SEEDS
Sections.MainSection4:Toggle({
	Name = "Auto Plant Seeds",
	Callback = function(value)
        getgenv().PlantSeeds = value
	end,
}, "Auto Plant Seeds")
--PLANT SEEDS DROPDOWN
Sections.MainSection4:Dropdown({
	Name = "Choose Seeds",
	Search = true,
	Multi = true,
	Required = false,
	Options = fruitArray,
	Default = {"Mango","Grape","Dragon Fruit","Durian","Pepper","Coconut","Cactus", "Cacao"},
    Callback = function(Value)
        SeedPlant = {} -- Clear old values
        for name, isSelected in pairs(Value) do
            if isSelected then
                table.insert(SeedPlant, name)
            end
        end
        print("Selected Seeds:", table.concat(SeedPlant, ", "))
    end,
}, "Choose Fruits")
--PLACE EGGS
Sections.MainSection5:Toggle({
	Name = "Auto Place Eggs",
	Callback = function(value)
        getgenv().PlaceEggs = value
	end,
}, "Auto Plant Eggs")
--PLACE EGGS DROPDOWN
Sections.MainSection5:Dropdown({
	Name = "Choose Eggs",
	Search = true,
	Multi = true,
	Required = false,
	Options = Eggs,
	Default = {"Premium Night Egg", "Night Egg", "Mythical Egg", "Legendary Egg","Bug Egg","Divine Egg","Exotic Bug Egg"},
    Callback = function(Value)
        PlaceEgg = {} -- Clear old values
        for name, isSelected in pairs(Value) do
            if isSelected then
                table.insert(PlaceEgg, name)
            end
        end
        print("Selected Egg:", table.concat(PlaceEgg, ", "))
    end,
}, "Choose Fruits")
--FAVORITE MOONLIGHT FRUITS
Sections.MainSection1:Toggle({
	Name = "Favorite Moonlight Fruits",
	Callback = function(value)
        getgenv().isFavor = value
	end,
}, "Favorite Moonlight Fruits")
--OFFER MOONLIGHT FRUITS
Sections.MainSection1:Toggle({
	Name = "Offer Moonlight Fruits",
	Callback = function(value)
        getgenv().isOffer = value
	end,
}, "Offer Moonlight Fruits")
--BUY FRUITS
Sections.MainSection1:Toggle({
	Name = "Auto Buy Fruits",
	Callback = function(value)
        getgenv().isBuyFruit = value
	end,
}, "Auto Buy Fruits")
--BUY GEARS
Sections.MainSection1:Toggle({
	Name = "Auto Buy Gears",
	Callback = function(value)
        getgenv().isBuyGear = value
	end,
}, "Auto Buy Gears")
--SELL FRUITS
Sections.MainSection1:Toggle({
	Name = "Auto Sell Fruits",
	Callback = function(value)
        getgenv().isSell = value
	end,
}, "Auto Sell Fruits")
--CLAIM DAILY
Sections.MainSection1:Toggle({
	Name = "Auto Claim Daily",
	Callback = function(value)
        getgenv().ClaimDaily = value
	end,
}, "Auto Claim Daily")

--BUY FRUITS
Sections.MainSection2:Dropdown({
	Name = "Choose Fruits",
	Search = true,
	Multi = true,
	Required = false,
	Options = fruitArray,
	Default = {"Mango","Grape","Dragon Fruit","Durian","Pepper","Coconut","Cactus", "Cacao"},
    Callback = function(Value)
        FruitBuy = {} -- Clear old values
        for name, isSelected in pairs(Value) do
            if isSelected then
                table.insert(FruitBuy, name)
            end
        end
        print("Selected Fruit:", table.concat(FruitBuy, ", "))
    end,
}, "Choose Fruits")

--BUY GEAR
local gear = require(game:GetService("ReplicatedStorage").Data.GearData)
local gearArray = {}
for _, v in pairs(gear) do
    table.insert(gearArray, v["GearName"])
end

Sections.MainSection2:Dropdown({
	Name = "Choose Gear",
	Search = true,
	Multi = true,
	Required = false,
	Options = gearArray,
	Default = {"Basic Sprinkler","Master Sprinkler","Advanced Sprinkler","Godly Sprinkler"},
    Callback = function(Value)
        GearBuy = {}
        for name, isSelected in pairs(Value) do
            if isSelected then
                table.insert(GearBuy, name)
            end
        end
        print("Selected Gear:", table.concat(GearBuy, ", "))
    end,
}, "Choose Gear")

Sections.MainSection3:Paragraph({
    Header = "⚠️ Loading Status | Waiting for Action...",
    Body = ""
}, "LiveStatus")




-- WEBHOOK SECTIONS ##############################################################################
Sections.WebhookSection1:Header({
	Text = "Webhook",
}, "Webhook")

--WEBHOOK FUNCTION
local function WebhookUpdate()
    local playerSheckles = player.leaderstats.Sheckles
    local webhookColor = 16766311
    local currentWeather = nil

    --GET WEATHER
    local WeatherFrame = game:GetService("Players").LocalPlayer.PlayerGui.Bottom_UI.BottomFrame.Holder.List

    for _, weather in pairs(WeatherFrame:GetDescendants())do
        if weather:IsA("Frame") and weather.Visible then
            currentWeather = weather.Name
        end
    end

    --CHANGE COLOR
    if currentWeather == "Frost" then
        webhookColor = 13425151
    elseif currentWeather == "Luck" then
        webhookColor = 5963607
    elseif currentWeather == "Night" then
        webhookColor = 6304427
    elseif currentWeather == "Rain" then
        webhookColor = 6061055
    elseif currentWeather == "Thunderstorm" then
        webhookColor = 16121646
    end


    --GET FRUIT STOCKS
    local FruitSlot = ""
    local SeedStock = player.PlayerGui.Seed_Shop.Frame.ScrollingFrame
    for _, seed in pairs(SeedStock:GetChildren()) do
        if seed:IsA("Frame") and #seed:GetChildren() >= 3 then
            local frame = seed:FindFirstChild("Main_Frame")
            if frame then
                if frame.Cost_Text.Text ~= "NO STOCK" then
                    FruitSlot = FruitSlot .. "[" .. frame.Rarity_Text.Text .. "] ".. frame.Seed_Text.Text .. " | " .. frame.Cost_Text.Text .. " | " ..frame.Stock_Text.Text .. "\n"
                end
            end
        end
    end
    --GET GEAR STOCKS
    local GearSlot = ""
    local GearStock = player.PlayerGui.Gear_Shop.Frame.ScrollingFrame
    for _, gear in pairs(GearStock:GetChildren()) do
        if gear:IsA("Frame") and #gear:GetChildren() >= 3 then
            local frame = gear:FindFirstChild("Main_Frame")
            if frame then
                if frame.Cost_Text.Text ~= "NO STOCK" then
                    GearSlot = GearSlot .. "[" .. frame.Rarity_Text.Text .. "] " .. frame.Gear_Text.Text .. " | " .. frame.Cost_Text.Text .. " | " ..frame.Stock_Text.Text .."\n"
                end
            end
        end
    end

    local getid = getgenv().WebhookID or ""
    local discorduserid = getid ~= "" and "<@" .. getid .. ">" or ""

    local response = request({
    Url = getgenv().WebhookURL,
    Method = "POST",
    Headers = {
        ["Content-Type"] = "application/json"
    },
    Body = HttpService:JSONEncode({
        ["content"] = discorduserid,
        ["embeds"] = {{
            ["title"] = "Player Name: ||" .. player.Name .. "||",
            ["description"] = "",
            ["type"] = "rich",
            ["color"] = webhookColor,
            ["author"] = {
                ["name"] = "Rinn Hub | Grow a Garden",
                ["icon_url"] = "https://media.discordapp.net/attachments/1365712111946174495/1369359622040977539/Gehlee_copy.png"
            },
            ["thumbnail"] = {
                ["url"] = "https://media.discordapp.net/attachments/1365712111946174495/1369359622040977539/Gehlee_copy.png"
            },
            ["fields"] = {
                {
                    ["name"] = "Player Sheckles : ",
                    ["value"] = FormatNumbers(playerSheckles.Value),
                    ["inline"] = false
                },
                {
                    ["name"] = "🌕 Weather: ",
                    ["value"] =  currentWeather or "Normal",
                },
                {
                    ["name"] = "🌱 Seed Stock: ",
                    ["value"] =  FruitSlot,
                },
                {
                    ["name"] = "⚙️ Gear Stock: ",
                    ["value"] =  GearSlot,
                }
            },
            ["footer"] = {
                ["text"] = "https://discord.gg/zBDGASMec7",
                ["icon_url"] = "https://media.discordapp.net/attachments/1365712111946174495/1369359622040977539/Gehlee_copy.png"
            }
        }},
        ["username"] = "Rinn Hub | Grow a Garden"
    })
})

end

-- Webhook URL
Sections.WebhookSection1:Input({
	Name = "Webhook URL",
	Placeholder = "URL",
	AcceptedCharacters = "All",
	Callback = function(input)
        getgenv().WebhookURL = input
        print("Webhook URL Set | ".. input)
	end,
}, "Webhook URL")
--Webhook ID
Sections.WebhookSection1:Input({
	Name = "User ID",
	Placeholder = "ID",
	AcceptedCharacters = function(input)
		return input:gsub("[^a-zA-Z0-9]", "") -- AlphaNumeric sub
	end,
	Callback = function(input)
        getgenv().WebhookID = input
        print("Webhook ID Set | ".. input)
	end,
}, "User ID")
--Webhook Every XX
Sections.WebhookSection1:Input({
	Name = "Send Every XX",
	Placeholder = "Minutes",
	AcceptedCharacters = function(input)
		return input:gsub("[^a-zA-Z0-9]", "") -- AlphaNumeric sub
	end,
	Callback = function(input)
        getgenv().WebhookWait = input
        print("Webhook Time Set | ".. input)
	end,
}, "User ID")
--Webhook Toggle
Sections.WebhookSection1:Toggle({
	Name = "Enable Webhook",
	Callback = function(value)
        getgenv().WebhookToggle = value
        task.spawn(function ()
            while getgenv().WebhookToggle do
                task.wait(getgenv().WebhookWait * 60)
                WebhookUpdate()
            end
        end)
	end,
}, "Enable Webhook")
--Webhook Test
Sections.WebhookSection1:Button({
    Name = "Test Webhook",
    Callback = function()
        WebhookUpdate()
    end,
})

-- MISC SECTIONS ##############################################################################
Sections.GuiSection1:Header({
	Text = "Open UI",
}, "Misc")
Sections.GuiSection2:Header({
	Text = "Character Mods",
}, "Misc")

--OPEN SEED SHOP
Sections.GuiSection1:Toggle({
	Name = "Open Seed Shop",
	Callback = function(value)
        local SeedShop = player.PlayerGui.Seed_Shop
        SeedShop.Enabled = value
	end,
}, "Open Seed Shop")

--OPEN GEAR SHOP
Sections.GuiSection1:Toggle({
	Name = "Open Gear Shop",
	Callback = function(value)
        local GearShop = player.PlayerGui.Gear_Shop
        GearShop.Enabled = value
	end,
}, "Open Gear Shop")

--OPEN NIGHT QUEST
Sections.GuiSection1:Toggle({
	Name = "Open Lunar Glow",
	Callback = function(value)
        local LunarGlow = player.PlayerGui.NightQuest_UI
        LunarGlow.Enabled = value
	end,
}, "Open Lunar Glow")

--OPEN NIGHT QUEST
Sections.GuiSection1:Toggle({
	Name = "Open Daily Quest",
	Callback = function(value)
        local LunarGlow = player.PlayerGui.DailyQuests_UI
        LunarGlow.Enabled = value
	end,
}, "Open Daily Quest")

--WALKSPEED
Sections.GuiSection2:Slider({
	Name = "WalkSpeed",
	Default = 30,
	Minimum = 16,
	Maximum = 150,
	DisplayMethod = "Round",
	Callback = function(Value)
		human.WalkSpeed = Value
	end,
}, "WalkSpeed")
--JUMP POWER
Sections.GuiSection2:Slider({
	Name = "Jump Power",
	Default = 50,
	Minimum = 50,
	Maximum = 200,
	DisplayMethod = "Round",
	Callback = function(Value)
		human.JumpPower = Value
	end,
}, "JumpPower")


--GIFT TAB ###############################################################################

--GIFT SECTIONS
Sections.GiftSection1:Header({
	Text = "Auto Gift Player",
}, "Main")
Sections.GiftSection1:SubLabel({
  Text = "Must be on with Enable Farm to work"
}, "Main")


--PLAYER DROPDOWN
Sections.GiftSection1:Dropdown({
	Name = "Player Dropdown",
	Search = true,
	Multi = false,
	Required = false,
	Options = PlayerDropdown,
    Callback = function(Value)
        getgenv().GiftPlayer = Value
        print("Selected Player:", Value)
    end,
}, "Player Dropdown")
-- REFRESH DROPDOWNS
Sections.GiftSection1:Button({
    Name = "Refresh Dropdowns",
    Callback = function()
        PlayerDropdown = {}
        for _, v in pairs(PlayerList:GetChildren()) do
        table.insert(PlayerDropdown, v.Name)
        end

        -- Refresh Player Dropdown
        MacLib.Options["Player Dropdown"]:ClearOptions()
        MacLib.Options["Player Dropdown"]:InsertOptions(PlayerDropdown)
        MacLib.Options["Player Dropdown"]:UpdateSelection("") 
    end,
})
--AUTO GIFT
Sections.GiftSection1:Toggle({
	Name = "Auto Gift",
	Callback = function(value)
        getgenv().AutoGift = value
	end,
}, "Auto Gift")

Tabs.Main:Select()
--AUTO ACCEPT
Sections.GiftSection1:Toggle({
	Name = "Auto Accept",
	Callback = function(value)
        getgenv().AutoAccept = value
	end,
}, "Auto Accept")

Tabs.Main:Select()
