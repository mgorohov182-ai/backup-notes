-- loader.lua – Финальная версия с отладкой (Gist)
local player = game.Players.LocalPlayer
local userId = tostring(player.UserId)

-- Функции для работы с файлами (для сохранения ключа)
local function readFile(name)
    local f, err = loadfile(name)
    if f then return f() end
    return nil
end

local function writeFile(name, data)
    local f = io.open(name, "w")
    if f then f:write(data) f:close() end
end

-- Загружаем сохранённый ключ, если есть
local key = readFile("nano_key.txt") or ""

if key == "" then
    -- Создаём простое окно для ввода ключа
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

    local textCorner = Instance.new("UICorner")
    textCorner.CornerRadius = UDim.new(0, 6)
    textCorner.Parent = textbox

    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.Size = UDim2.new(0.4, 0, 0, 35)
    btn.Position = UDim2.new(0.3, 0, 0.7, 0)
    btn.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    btn.Text = "ПОДТВЕРДИТЬ"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        key = textbox.Text
        if key and key ~= "" then
            writeFile("nano_key.txt", key)
            gui:Destroy()
        end
    end)

    -- Ждём, пока ключ не будет введён
    repeat task.wait() until key and key ~= ""
end

-- ⚠️ ЗАМЕНИ ЭТУ ССЫЛКУ на свою (от Google Sheets с ключами)
local csvUrl = "https://docs.google.com/spreadsheets/d/e/2PACX-1vSnarWFrJRkrKPFvOMN7NUYttvLFy_Wg0LfnnQQDMEVduwD_-Lo0HLfy0X7m_J2KBQ9aJf4I8ylTAWh/pub?output=csv"

local valid = false
local csv = game:HttpGet(csvUrl)

for line in csv:gmatch("[^\r\n]+") do
    -- Пропускаем заголовок
    if not line:match("^key") then
        local k, uid = line:match("([^,]+),([^,]+)")
        if k and uid then
            -- Убираем возможные пробелы
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
    local obfuscatedUrl = "https://gist.githubusercontent.com/mgorohov182-ai/36331efd95e6a7560d10a333a0d11a34/raw/396f683dfab1de5832f14177d617cfff3b15cbad/original.obfuscated.lua"
    local obfuscatedCode = game:HttpGet(obfuscatedUrl)

    -- Проверяем, что код получен
    if obfuscatedCode and #obfuscatedCode > 0 then
        local func = loadstring(obfuscatedCode)
        if func then
            func()
        else
            warn("Ошибка: loadstring не смог выполнить код. Возможно, код повреждён.")
            -- Выведем первые 100 символов для отладки
            print("Первые 100 символов кода:", obfuscatedCode:sub(1,100))
        end
    else
        warn("Ошибка: не удалось загрузить код по ссылке. Ссылка недействительна?")
    end
else
    player:Kick("Неверный ключ или доступ запрещён")

end


