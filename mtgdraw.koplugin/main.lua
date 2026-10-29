local ButtonDialog = require("ui/widget/buttondialog")
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")

-- KOReader crea un'istanza di questo plugin al caricamento.
local MTGDraw = WidgetContainer:extend{
    name = "mtgdraw",
    is_doc_only = false, -- Disponibile anche senza un libro aperto.
}

function MTGDraw:init()
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
    -- Primo passo: verificare il collegamento tra pulsante ed evento.
    -- Qui aggiungeremo il recupero e la visualizzazione della carta.
    UIManager:show(InfoMessage:new{
        text = "Draw funziona!\nIl prossimo passo è visualizzare una carta.",
    })
end

return MTGDraw
