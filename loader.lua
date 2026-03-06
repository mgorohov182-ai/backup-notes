-- loader.lua – МАКСИМАЛЬНАЯ ОТЛАДКА
print(">>> ЗАГРУЗЧИК ЗАПУЩЕН")

local player = game.Players.LocalPlayer
local userId = tostring(player.UserId)
local HttpService = game:GetService("HttpService")
local keyFileName = "nano_key.json"

print(">>> UserId:", userId)

-- Функция для чтения ключа из файла JSON
local function readKeyFromFile()
    print(">>> Попытка чтения файла:", keyFileName)
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(keyFileName))
    end)
    if success and data and data.key then
        print(">>> Ключ прочитан из файла:", data.key)
        return data.key
    end
    print(">>> Ключ в файле не найден")
    return nil
end

-- Функция для записи ключа в файл JSON
local function writeKeyToFile(key)
    print(">>> Запись ключа в файл:", key)
    local data = HttpService:JSONEncode({key = key})
    writefile(keyFileName, data)
    print(">>> Ключ сохранён")
end

-- Загружаем сохранённый ключ, если есть
local key = readKeyFromFile() or ""
print(">>> Текущий ключ:", key)

if key == "" then
    print(">>> Ключ пуст, создаём окно ввода")
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
        print(">>> Ключ введён в окно:", key)
        if key and key ~= "" then
            writeKeyToFile(key)
            gui:Destroy()
        end
    end)

    repeat task.wait() until key and key ~= ""
    print(">>> Окно закрыто, ключ получен:", key)
end

-- Проверка ключа через Google Sheets
local csvUrl = "https://docs.google.com/spreadsheets/d/e/2PACX-1vSnarWFrJRkrKPFvOMN7NUYttvLFy_Wg0LfnnQQDMEVduwD_-Lo0HLfy0X7m_J2KBQ9aJf4I8ylTAWh/pub?output=csv"
print(">>> Загружаем CSV с ключами...")
local csv = game:HttpGet(csvUrl)
print(">>> CSV получен, длина:", #csv)

local valid = false
for line in csv:gmatch("[^\r\n]+") do
    if not line:match("^key") then
        local k, uid = line:match("([^,]+),([^,]+)")
        if k and uid then
            k = k:gsub("%s+", "")
            uid = uid:gsub("%s+", "")
            print(">>> Сравниваем: ключ из CSV =", k, "UserId из CSV =", uid, "с нашим ключом =", key, "и UserId =", userId)
            if k == key and uid == userId then
                valid = true
                break
            end
        end
    end
end

if valid then
    print(">>> КЛЮЧ ВАЛИДЕН! Загружаем обфусцированный код")
    local obfuscatedUrl = "https://gist.githubusercontent.com/mgorohov182-ai/36331efd95e6a7560d10a333a0d11a34/raw/3bce33ae8698a4c20819ccf4407eefcf87d59ce6/original.obfuscated.lua"
    print(">>> Загрузка по ссылке:", obfuscatedUrl)
    local obfuscatedCode = game:HttpGet(obfuscatedUrl)
    print(">>> Код загружен, длина:", obfuscatedCode and #obfuscatedCode or 0)

    if obfuscatedCode and #obfuscatedCode > 0 then
        print(">>> Компилируем код через loadstring...")
        local func, err = loadstring(obfuscatedCode)
        if func then
            print(">>> loadstring успешен, выполняем...")
            local success, execErr = pcall(func)
            if success then
                print(">>> Код выполнился без ошибок.")
            else
                print(">>> ОШИБКА выполнения кода:", execErr)
            end
        else
            print(">>> ОШИБКА loadstring:", err)
            print(">>> Первые 200 символов кода:", obfuscatedCode:sub(1,200))
        end
    else
        print(">>> ОШИБКА: код не загрузился (пустой ответ)")
    end
else
    print(">>> КЛЮЧ НЕ ВАЛИДЕН! Будет кик")
    player:Kick("Неверный ключ или доступ запрещён")
end

print(">>> ЗАГРУЗЧИК ЗАВЕРШИЛ РАБОТУ")



