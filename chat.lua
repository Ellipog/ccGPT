-- Check if we have http API enabled
if not http then
    error("HTTP API is required. Enable it in ComputerCraft config")
end

-- Configuration
local API_URL = "https://cc-gpt-beta.vercel.app/chat"  -- Change this to match your server URL

-- Function to make streaming request
local function makeStreamingRequest(message)
    local headers = {
        ["Content-Type"] = "application/json",
        ["User-Agent"] = "ComputerCraft"
    }
    
    local data = textutils.serializeJSON({
        message = message
    })

    local response = http.post({
        url = API_URL,
        body = data,
        headers = headers,
        binary = true
    })

    if not response then
        return nil, "Failed to connect to server"
    end

    return response
end

-- Function to handle cursor movement and word wrapping
local function smartPrint(text)
    local width, height = term.getSize()
    local x, y = term.getCursorPos()
    
    -- If we're at the bottom of the screen, scroll up
    if y >= height then
        term.scroll(1)
        y = height - 1
        term.setCursorPos(x, y)
    end
    
    -- Print the text and handle word wrapping
    term.write(text)
end

-- Main chat loop
local function main()
    term.clear()
    term.setCursorPos(1,1)
    print("ComputerCraft ChatGPT Terminal")
    print("Type 'exit' to quit")
    print("------------------------")

    while true do
        term.setTextColor(colors.yellow)
        write("> ")
        term.setTextColor(colors.white)
        
        local input = read()
        
        if input:lower() == "exit" then
            print("Goodbye!")
            break
        end
        
        term.setTextColor(colors.lime)
        print("\nBot: ")
        term.setTextColor(colors.white)
        
        -- Make streaming request
        local response, error = makeStreamingRequest(input)
        
        if not response then
            print("Error: " .. (error or "Unknown error"))
        else
            -- Process the streaming response
            local buffer = ""
            while true do
                local chunk = response.read()
                if not chunk then
                    break
                end
                
                -- Check for special end markers
                if chunk:match("^%[ERROR%]") then
                    term.setTextColor(colors.red)
                    print("\nError: " .. chunk:sub(8))
                    term.setTextColor(colors.white)
                    break
                elseif chunk:match("^%[DONE%]") then
                    break
                end
                
                -- Handle partial UTF-8 characters in buffer
                buffer = buffer .. chunk
                local validString = ""
                
                -- Process complete UTF-8 sequences
                while #buffer > 0 do
                    local char = string.match(buffer, "^[%z\1-\127\194-\244][\128-\191]*")
                    if not char then break end
                    validString = validString .. char
                    buffer = string.sub(buffer, #char + 1)
                end
                
                if #validString > 0 then
                    smartPrint(validString)
                end
            end
            response.close()
        end
        
        print("\n------------------------")
    end
end

-- Run the main function with error handling
local ok, err = pcall(main)
if not ok then
    term.setTextColor(colors.red)
    print("Error: " .. tostring(err))
    term.setTextColor(colors.white)
end
