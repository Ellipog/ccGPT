-- Simple chat client that connects to Node.js server with streaming support
local SERVER_URL = "https://cc-gpt-beta.vercel.app/chat"
local https = require("api") -- Import our new HTTPS API

-- Function to wrap text and print at current position
local function printWrapped(text, startX, startY)
    local width, height = term.getSize()
    local currentX, currentY = startX, startY
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
        
        term.write(word)
        currentX = currentX + #word
    end
    
    return currentX, currentY
end

-- Function to send message to server and handle streaming response
local function getStreamingResponse(message)
    -- Setup request data
    local headers = {
        ["Content-Type"] = "application/json",
        ["Accept"] = "text/event-stream",
        ["User-Agent"] = "ComputerCraft/1.0"
    }

    -- Make the HTTP request using our new API
    local response = https.postJSON(SERVER_URL, {
        message = message
    }, headers)

    if not response then
        print("Error: Failed to connect to server")
        return
    end

    -- Setup response display
    local currentX, currentY = term.getCursorPos()
    term.setCursorPos(1, currentY)
    term.write("Bot: ")
    currentX, currentY = term.getCursorPos()

    -- Process the streaming response
    local wordBuffer = ""
    
    while true do
        local line = response.readLine()
        if not line then break end

        -- Handle SSE data
        if line:match("^data: ") then
            local data = line:sub(6) -- Remove "data: " prefix
            
            -- Check for stream end
            if data == "[DONE]" then
                if #wordBuffer > 0 then
                    currentX, currentY = printWrapped(wordBuffer, currentX, currentY)
                end
                break
            end

            -- Parse and handle chunk data
            local success, chunk = pcall(textutils.unserializeJSON, data)
            if success and chunk and chunk.content then
                wordBuffer = wordBuffer .. chunk.content
                
                -- Print complete words
                if wordBuffer:match("[%s%p]$") then
                    currentX, currentY = printWrapped(wordBuffer, currentX, currentY)
                    wordBuffer = ""
                end
            end
        end
    end

    response.close()
    print() -- New line after response
end

-- Main program
term.clear()
term.setCursorPos(1,1)
print("ChatBot Started!")
print("Type your messages and press Enter")
print("Type 'exit' to quit")
print("------------------------")

-- Enable HTTP if not already enabled
if not https.get(SERVER_URL) then
    print("Warning: HTTPS must be enabled for this program")
    print("Run 'set http.strict_ssl false' in the shell")
    return
end

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