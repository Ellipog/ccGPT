-- Simple chat client that connects to local Node.js server with streaming support
local SERVER_URL = "http://localhost:3000/chat"

local messages = {}

-- Function to wrap text and print at current position
local function printWrapped(text, startX, startY)
    local width, height = term.getSize()
    local currentX, currentY = startX, startY
    
    -- Add spaces after punctuation if they don't exist
    text = text:gsub("([%p])", "%1 "):gsub("  ", " ")
    
    local words = {}
    
    -- Split into words while preserving spaces and punctuation
    for word in text:gmatch("[%S]+[%s%p]*") do
        table.insert(words, word)
    end
    
    for _, word in ipairs(words) do
        -- Check if word would exceed screen width
        if currentX + #word > width then
            currentX = 1
            currentY = currentY + 1
            term.setCursorPos(currentX, currentY)
        end
        
        -- Print word and update position
        term.write(word)
        currentX = currentX + #word
    end
    
    return currentX, currentY
end

-- Function to send message to server and handle streaming response
local function getStreamingResponse(message)
    local postData = textutils.serialiseJSON({
        message = message
    })

    table.insert(messages, "user: " .. message)

    local response = http.post(
        SERVER_URL,
        "string",
        {
            ["x-message"] = textutils.serialiseJSON(messages), 
            ["x-role"] = "You are a computer craft computer inside someones minecraft base, you will always start your response with 'Bot: ', and "
        }
    )

    if not response then
        return "Error: Failed to connect to server"
    end

    -- Get starting position for response
    local currentX, currentY = term.getCursorPos()
    term.setCursorPos(1, currentY)
    currentX, currentY = term.getCursorPos()

    -- Buffer to store complete response
    local completeResponse = ""
    local wordBuffer = ""
    
    -- Read the stream line by line
    while true do
        local line = response.readLine()
        if not line then break end

        if line:match("^data: ") then
            local data = line:sub(6)
            
            if data == "[DONE]" then
                -- Print any remaining buffered text
                if #wordBuffer > 0 then
                    currentX, currentY = printWrapped(wordBuffer, currentX, currentY)
                end
                -- Add complete response to messages table
                table.insert(messages, "bot: " .. completeResponse)
                break
            end

            local ok, chunk = pcall(textutils.unserializeJSON, data)
            if ok and chunk and chunk.content then
                -- Remove "Bot: " prefix if it exists
                local content = chunk.content:gsub("^Bot: ", "")
                completeResponse = completeResponse .. content
                wordBuffer = wordBuffer .. content
                
                -- If we have a complete word (space or punctuation), print the buffer
                if wordBuffer:match("[%s%p]$") then
                    currentX, currentY = printWrapped(wordBuffer, currentX, currentY)
                    wordBuffer = ""
                end
            end
        end
    end

    response.close()
    print() -- New line after response is complete
end

-- Main program
term.clear()
term.setCursorPos(1,1)
print("ChatBot Started!")
print("Type your messages and press Enter")
print("Type 'exit' to quit")
print("------------------------")

-- Main loop
while true do
    term.write("> ")
    local input = read()
    
    if input:lower() == "exit" then
        print("Goodbye!")
        break
    end
    
    print("Thinking...")
    getStreamingResponse(input)
    print("------------------------")
end