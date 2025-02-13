local request = http.get("https://example.tweaked.cc")
print(request.readAll())

request.close()

local headers = {
    ["Content-Type"] = "application/json",
    ["User-Agent"] = "ComputerCraft"
}

local message = {
    message = "hello chatgpt"
}

local response = http.post(
    "https://cc-gpt-beta.vercel.app/chat",
    textutils.serializeJSON(message),
    headers
)

if response then
    local content = response.readAll()
    response.close()
    
    local data = textutils.unserializeJSON(content)
    print(data.content)
else
    print("Failed to connect to server")
end

