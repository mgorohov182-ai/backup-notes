-- loader.lua – Финальная версия без loadfile (с хранением ключа через HttpService)
local player = game.Players.LocalPlayer
local userId = tostring(player.UserId)
local HttpService = game:GetService("HttpService")
local keyFileName = "nano_key.json" -- теперь будем хранить ключ в JSON

-- Функция для чтения ключа из файла JSON
local function readKeyFromFile()
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(keyFileName))
    end)
    if success and data and data.key then
        return data.key
    end
    return nil
end

-- Функция для записи ключа в файл JSON
local function writeKeyToFile(key)
    local data = HttpService:JSONEncode({key = key})
    writefile(keyFileName, data)
end

-- Загружаем сохранённый ключ, если есть
local key = readKeyFromFile() or ""

if key == "" then
    -- Создаём окно для ввода ключа (без изменений)
    local gui = Instance.new("ScreenGui")
    gui.Parent = player.PlayerGui
    gui.Name = "KeySystem"

    local frame = Instance.new("Frame")
    frame.Parent = gui
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    frame.BackgroundTransparency = 0.1
    frame.Active = true
    frame.Draggable = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(1, 0, 0, 30)
    label.Position = UDim2.new(0, 0, 0, 15)
    label.BackgroundTransparency = 1
    label.Text = "🔐 ВВЕДИТЕ КЛЮЧ"
    label.TextColor3 = Color3.fromRGB(220, 220, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16

    local textbox = Instance.new("TextBox")
    textbox.Parent = frame
    textbox.Size = UDim2.new(0.8, 0, 0, 35)
    textbox.Position = UDim2.new(0.1, 0, 0.4, 0)
    textbox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    textbox.PlaceholderText = "Введите ключ"
    textbox.Text = ""
    textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textbox.Font = Enum.Font.Gotham
    textbox.TextSize = 14

    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.Size = UDim2.new(0.4, 0, 0, 35)
    btn.Position = UDim2.new(0.3, 0, 0.7, 0)
    btn.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    btn.Text = "ПОДТВЕРДИТЬ"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14

    btn.MouseButton1Click:Connect(function()
        key = textbox.Text
        if key and key ~= "" then
            writeKeyToFile(key)
            gui:Destroy()
        end
    end)

    repeat task.wait() until key and key ~= ""
end

-- Проверка ключа через Google Sheets (без изменений)
local csvUrl = "https://docs.google.com/spreadsheets/d/e/2PACX-1vSnarWFrJRkrKPFvOMN7NUYttvLFy_Wg0LfnnQQDMEVduwD_-Lo0HLfy0X7m_J2KBQ9aJf4I8ylTAWh/pub?output=csv" -- ⚠️ Убедись, что это твоя ссылка!

local valid = false
local csv = game:HttpGet(csvUrl)

for line in csv:gmatch("[^\r\n]+") do
    if not line:match("^key") then
        local k, uid = line:match("([^,]+),([^,]+)")
        if k and uid then
            k = k:gsub("%s+", "")
            uid = uid:gsub("%s+", "")
            if k == key and uid == userId then
                valid = true
                break
            end
        end
    end
end

if valid then
    -- Загружаем обфусцированный код с GitHub Gist
    local obfuscatedUrl = "https://gist.githubusercontent.com/mgorohov182-ai/36331efd95e6a7560d10a333a0d11a34/raw/6d34006ac7356f1a07cddf92a13ba2423d614eba/original.obfuscated.lua" -- ⚠️ Убедись, что это твоя рабочая ссылка!
    local obfuscatedCode = game:HttpGet(obfuscatedUrl)

    if obfuscatedCode and #obfuscatedCode > 0 then
        local func = loadstring(obfuscatedCode)
        if func then
            func()
        else
            warn("Ошибка компиляции loadstring. Первые 100 символов кода:", obfuscatedCode:sub(1,100))
        end
    else
        warn("Не удалось загрузить код по ссылке:", obfuscatedUrl)
    end
else
    player:Kick("Неверный ключ или доступ запрещён")
end



