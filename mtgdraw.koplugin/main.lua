local ButtonDialog = require("ui/widget/buttondialog")
local DataStorage = require("datastorage")
local ImageViewer = require("ui/widget/imageviewer")
local InfoMessage = require("ui/widget/infomessage")
local NetworkMgr = require("ui/network/manager")
local Trapper = require("ui/trapper")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")

-- KOReader crea un'istanza di questo plugin al caricamento.
local MTGDraw = WidgetContainer:extend{
    name = "mtgdraw",
    is_doc_only = false, -- Disponibile anche senza un libro aperto.
}

function MTGDraw:init()
    self.scryfall = dofile(self.path .. "/scryfall.lua")
    self.ui.menu:registerToMainMenu(self)
end

-- KOReader chiama questo metodo per raccogliere le voci del menu.
function MTGDraw:addToMainMenu(menu_items)
    menu_items.mtgdraw = {
        text = "MTG Draw",
        sorting_hint = "more_tools",
        callback = function()
            self:showDrawDialog()
        end,
    }
end

function MTGDraw:showDrawDialog()
    UIManager:show(ButtonDialog:new{
        title = "MTG Draw",
        title_align = "center",
        buttons = {
            {
                {
                    text = "Draw",
                    callback = function()
                        self:drawCard()
                    end,
                },
            },
        },
    })
end

function MTGDraw:drawCard()
    NetworkMgr:runWhenOnline(function()
        if self.loading then return end
        self.loading = true
        Trapper:wrap(function()
            -- La rete gira in un processo separato: l'interfaccia resta reattiva.
            local ok, err = pcall(function()
                local completed, card = Trapper:dismissableRunInSubprocess(function()
                    return self.scryfall.fetchRandom()
                end, "Scaricamento da Scryfall…\nTocca per annullare.")
                if not completed then return end
                if not card or card.error then
                    error(card and card.error or "Download interrotto senza risultato.", 0)
                end
                self:showCard(card)
            end)
            self.loading = false
            if not ok then
                UIManager:show(InfoMessage:new{ text = tostring(err) })
            end
        end)
    end)
end

function MTGDraw:showCard(card)
    -- Conserviamo solo l'ultima immagine, nella cache di KOReader.
    local path = DataStorage:getDataDir() .. "/cache/mtgdraw-card.jpg"
    local temporary = path .. ".part"
    local file, err = io.open(temporary, "wb")
    if not file then error("Impossibile salvare la carta: " .. tostring(err), 0) end
    local written, write_err = file:write(card.image)
    local closed, close_err = file:close()
    if not written or not closed then
        os.remove(temporary)
        error("Impossibile salvare la carta: " .. tostring(write_err or close_err), 0)
    end
    local renamed, rename_err = os.rename(temporary, path)
    if not renamed then
        os.remove(temporary)
        error("Impossibile salvare la carta: " .. tostring(rename_err), 0)
    end
    UIManager:show(ImageViewer:new{
        file = path,
        title_text = card.name,
        fullscreen = true,
        scale_factor = 0, -- Adatta allo schermo mantenendo le proporzioni.
    })
end

return MTGDraw
