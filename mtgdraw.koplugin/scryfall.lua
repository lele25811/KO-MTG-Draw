-- Questo modulo si occupa solo della rete, senza modificare l'interfaccia.
local https = require("ssl.https")
local json = require("json")
local socketutil = require("socketutil")

local Scryfall = {}

local function get(url, accept, max_bytes)
    local chunks, size = {}, 0
    local sink = socketutil.table_sink(chunks)
    local ok, result, code = pcall(https.request, {
        url = url,
        method = "GET",
        headers = {
            ["User-Agent"] = "MTGDraw/0.1 (KOReader learning plugin)",
            ["Accept"] = accept,
        },
        sink = function(chunk, err)
            if chunk then
                size = size + #chunk
                if size > max_bytes then
                    return nil, "Risposta troppo grande"
                end
            end
            return sink(chunk, err)
        end,
    })
    if not ok then
        return nil, "Errore di connessione: " .. tostring(result)
    end
    if result ~= 1 or tonumber(code) ~= 200 then
        return nil, "Richiesta non riuscita: " .. tostring(code or result)
    end
    return table.concat(chunks)
end

function Scryfall.fetchRandom()
    socketutil:set_timeout(10, 30)
    -- pcall permette di ripristinare i timeout anche in caso di errore.
    local ok, result = pcall(function()
        local body, err = get("https://api.scryfall.com/cards/random",
            "application/json", 1024 * 1024)
        if not body then return { error = err } end

        local decoded, card = pcall(json.decode, body)
        if not decoded or type(card) ~= "table" or card.object ~= "card" then
            return { error = "Scryfall ha restituito dati non validi." }
        end

        local images = card.image_uris
        if not images and type(card.card_faces) == "table" then
            local front = card.card_faces[1]
            images = front and front.image_uris
        end
        local url = images and images.normal
        if type(url) ~= "string" or not url:match("^https://") then
            return { error = "Questa carta non ha un'immagine disponibile." }
        end

        local image, image_err = get(url, "image/jpeg", 5 * 1024 * 1024)
        if not image then return { error = image_err } end
        -- Evita di passare al visualizzatore una pagina di errore HTML.
        if image:sub(1, 3) ~= "\255\216\255" then
            return { error = "L'immagine ricevuta non è un JPEG valido." }
        end
        return { name = card.name or "Magic", image = image }
    end)
    socketutil:reset_timeout()
    if not ok then
        return { error = "Impossibile recuperare la carta: " .. tostring(result) }
    end
    return result
end

return Scryfall
