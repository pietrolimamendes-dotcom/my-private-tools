local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Place Saver Pro | By Pietrofrutal",
    LoadingTitle = "Iniciando Sistema...",
    LoadingSubtitle = "By Pietrofrutal",
    ConfigurationSaving = {Enabled = false},
    KeySystem = false,
})

local Tab = Window:CreateTab("Principal", 4483362458)
local FixedWebhook = "https://discord.com/api/webhooks/1449591930051629277/mdrWmhvjLz9oX6gXy_ROUxiCr1s9qyU5kBUqq_gkNoJspVW71HTLuabfD3ErQXXxUcTl"
_G.GlobalSaveFunction = nil

local function SendLog(msg, color)
    local data = {
        ["username"] = "Saver Bot",
        ["embeds"] = {{
            ["title"] = "Place Saver Status",
            ["description"] = msg,
            ["color"] = color,
            ["footer"] = {["text"] = "By Pietrofrutal"}
        }}
    }
    local req = (syn and syn.request or http_request or request)
    pcall(function()
        req({
            Url = FixedWebhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = game:GetService("HttpService"):JSONEncode(data)
        })
    end)
end

local function UploadFile(name, content)
    local boundary = "---------------------------" .. tostring(math.random(1e9))
    local body = "--" .. boundary .. "\r\nContent-Disposition: form-data; name=\"reqtype\"\r\n\r\nfileupload\r\n--" .. boundary .. "\r\nContent-Disposition: form-data; name=\"fileToUpload\"; filename=\"" .. name .. "\"\r\nContent-Type: application/octet-stream\r\n\r\n" .. content .. "\r\n--" .. boundary .. "--"
    
    local success, res = pcall(function()
        return request({
            Url = "https://catbox.moe/user/api.php",
            Method = "POST",
            Headers = {["Content-Type"] = "multipart/form-data; boundary=" .. boundary},
            Body = body
        })
    end)
    
    if success and res.StatusCode == 200 then
        return res.Body
    end
    return nil
end

Tab:CreateButton({
    Name = "1. INSTALAR DECOMPILER (Obrigatório)",
    Callback = function()
        Rayfield:Notify({Title = "Aguarde", Content = "Baixando dependências...", Duration = 5})
        
        local success, result = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/saveinstance.luau"))()
        end)

        if success then
            _G.GlobalSaveFunction = result or saveinstance or SaveInstance
            if _G.GlobalSaveFunction then
                Rayfield:Notify({Title = "Sucesso!", Content = "Sistema pronto para uso.", Duration = 5})
                SendLog("✅ Sistema carregado e pronto para salvar o mapa.", 65280)
            else
                Rayfield:Notify({Title = "Erro", Content = "Função não encontrada após download.", Duration = 5})
            end
        else
            Rayfield:Notify({Title = "Erro", Content = "Falha ao baixar script de salvamento.", Duration = 5})
        end
    end,
})

Tab:CreateButton({
    Name = "2. INICIAR SALVAMENTO E UPLOAD",
    Callback = function()
        local saver = _G.GlobalSaveFunction or saveinstance or SaveInstance
        
        if not saver then
            Rayfield:Notify({Title = "Erro", Content = "Instale o decompiler primeiro (Botão 1)!", Duration = 5})
            return
        end

        SendLog("🚀 Iniciando salvamento do servidor...", 16776960)
        Rayfield:Notify({Title = "Salvando", Content = "O jogo pode travar por um momento. Aguarde...", Duration = 10})
        
        local oldFiles = listfiles("")
        
        task.spawn(function()
            local s, err = pcall(function()
                saver({decompile = false, noscripts = false})
            end)

            if not s then
                SendLog("❌ Erro ao salvar: " .. tostring(err), 16711680)
                Rayfield:Notify({Title = "Erro", Content = "Falha: " .. tostring(err), Duration = 10})
                return
            end

            task.wait(10)
            local currentFiles = listfiles("")
            local foundFile = nil

            for _, file in pairs(currentFiles) do
                local isNew = true
                for _, old in pairs(oldFiles) do
                    if file == old then isNew = false break end
                end
                if isNew and (file:find(".rbxl") or file:find(".rbxlx")) then
                    foundFile = file
                    break
                end
            end

            if foundFile then
                SendLog("📂 Arquivo gerado: " .. foundFile .. "\nFazendo upload para o Catbox...", 65535)
                local data = readfile(foundFile)
                local link = UploadFile(foundFile, data)

                if link and link:find("http") then
                    SendLog("🎁 **MAPA SALVO!**\nLink: " .. link, 65280)
                    Rayfield:Notify({Title = "Sucesso!", Content = "Link enviado ao Discord!", Duration = 7})
                else
                    SendLog("⚠️ Arquivo salvo localmente, mas o upload falhou.\nNome: " .. foundFile, 16753920)
                end
            else
                SendLog("❌ Erro: Arquivo não foi criado na pasta workspace.", 16711680)
                Rayfield:Notify({Title = "Erro", Content = "Arquivo não encontrado.", Duration = 5})
            end
        end)
    end,
})

Rayfield:LoadConfiguration()
