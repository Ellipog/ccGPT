-- Check if HTTP API is enabled
if not http then
    error("HTTP API is required. Enable it in ComputerCraft config")
end

-- Config
local API_URL = "https://cc-gpt-beta.vercel.app/chat"

-- Simple request function
local function sendMessage(message)
    local response = http.post(
        API_URL,
        textutils.serializeJSON({ message = message }),
        { ["Content-Type"] = "application/json" }
    )
    
    if not response then
        return false, "Failed to connect to server"
    end
    
    return response
end

-- Main loop
term.clear()
term.setCursorPos(1,1)
print("ComputerCraft ChatGPT Terminal")
print("Type 'exit' to quit")
print("------------------------")

while true do
    -- Get input
    term.setTextColor(colors.yellow)
    write("> ")
    term.setTextColor(colors.white)
    local input = read()
    
    if input:lower() == "exit" then
        print("Goodbye!")
        break
    end
    
    -- Send and get response
    term.setTextColor(colors.lime)
    write("Bot: ")
    term.setTextColor(colors.white)
    
    local response = sendMessage(input)
    if not response then
        print("Error connecting to server")
    else
        while true do
            local line = response.read()
            if not line then break end
            write(line)
        end
        response.close()
    end
    
    print("\n------------------------")
end
