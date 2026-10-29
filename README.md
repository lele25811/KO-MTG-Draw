# MTG Draw for KOReader

MTG Draw is a KOReader plugin written in Lua that displays a random
**Magic: The Gathering** card from Scryfall. It is a learning project for
exploring Lua and plugin development for e-ink readers, starting with the Kobo Clara HD.

## How it works

Open **MTG Draw** from the tools menu and press **Draw**: the plugin downloads
a random card from Scryfall and displays its image scaled to fit the screen.
Close the image and press **Draw** again to draw another card.

An Internet connection is required, but no API key is needed. Downloads can
be cancelled, and any errors are displayed on screen. For double-faced cards,
only the first face is shown. The same card may appear more than once.

## Installation

Copy the `mtgdraw.koplugin` folder into KOReader's `plugins/` directory
(usually `.adds/koreader/plugins/` on Kobo devices) and restart KOReader.
