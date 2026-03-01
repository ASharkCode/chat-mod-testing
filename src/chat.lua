local geode = require("geode")
local globed = require("globed")

local ChatMod = {}

-- Config
ChatMod.fadeTime = 5         -- seconds until message fades
ChatMod.maxCornerMessages = 5
ChatMod.chatSound = nil      -- optional: "assets/chat_sound.wav"

-- Table to store chat history
ChatMod.history = {}

-- Add message to corner UI
function ChatMod:addCornerMessage(playerName, message)
    table.insert(ChatMod.history, playerName .. ": " .. message)
    if #ChatMod.history > ChatMod.maxCornerMessages then
        table.remove(ChatMod.history, 1)
    end

    -- Show in corner
    geode.ui.showMessage(playerName .. ": " .. message, ChatMod.fadeTime)

    -- Optional sound
    if ChatMod.chatSound then
        geode.audio.playSound(ChatMod.chatSound)
    end
end

-- Add message above player's head
function ChatMod:addAboveHeadMessage(playerId, message)
    local player = globed.players[playerId]
    if player and player.character and player.character.head then
        geode.ui.createFloatingText(player.character.head, message, ChatMod.fadeTime)
    end
end

-- Handle incoming chat messages
function ChatMod:onChat(playerId, message)
    local playerName = globed.players[playerId] and globed.players[playerId].name or "Unknown"
    self:addCornerMessage(playerName, message)
    self:addAboveHeadMessage(playerId, message)
end

-- Listen for / command
globed.events.onCommand(function(playerId, command, args)
    if command == "/" then
        local message = table.concat(args, " ")
        ChatMod:onChat(playerId, message)
    end
end)

-- Optional: /history command
globed.events.onCommand(function(playerId, command)
    if command == "/history" then
        local fullText = table.concat(ChatMod.history, "\n")
        geode.ui.showMessage("Chat History:\n" .. fullText, 10)
    end
end)

-- Debug print to confirm loading
print("GlobedTextChat loaded successfully!")

return ChatMod
