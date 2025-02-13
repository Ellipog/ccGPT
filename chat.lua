local function streamResponse(message)
    -- Convert message to JSON format
    local jsonData = textutils.serializeJSON({
        message = message
    })

    -- Make POST request with proper headers
    local response = http.post(
        "https://cc-gpt-beta.vercel.app/chat",
        jsonData,
        {["Content-Type"] = "application/json"}
    )
    
    if not response then
        error("Failed to connect to server")
    end
    
    local buffer = ""
    while true do
        local char = response.read(1)
        if not char then break end
        
        buffer = buffer .. char
        if char == "\n" and buffer:match("^data: ") then
            local data = buffer:match("^data: (.+)\n\n")
            if data then
                if data == "[DONE]" then break end
                
                local success, parsed = pcall(textutils.unserializeJSON, data)
                if success and parsed and parsed.content then
                    term.write(parsed.content)
                end
                buffer = ""
            end
        end
    end
    response.close()
end

-- Test the function
streamResponse("Hello, how are you?")