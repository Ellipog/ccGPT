# ccGPT - ComputerCraft GPT Integration

A chat interface that integrates OpenAI's GPT models with ComputerCraft computers in Minecraft, featuring a Node.js backend server and a Lua client.

## Features

- Real-time streaming chat responses
- ComputerCraft-aware chat interface
- Text wrapping and formatting for ComputerCraft terminals
- Express.js backend with OpenAI integration
- Easy-to-use Lua client for ComputerCraft computers

## Prerequisites

- Node.js (Latest LTS version recommended)
- OpenAI API key
- ComputerCraft mod installed in Minecraft
- Advanced Computer in ComputerCraft

## Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/ccGPT.git
cd ccGPT
```

2. Install dependencies:

```bash
npm install
```

3. Create a `.env` file in the root directory and add your OpenAI API key:

```
OPENAI_API_KEY=your_api_key_here
```

## Server Setup

1. Start the server:

```bash
npm start
```

The server will run on port 3000 by default. You can change this by setting the `PORT` environment variable.

## ComputerCraft Setup

1. Copy the contents of `chat.lua` to your ComputerCraft computer
2. Make sure your computer has internet access enabled in the ComputerCraft config
3. Run the chat program:

```lua
chat
```

## Usage

1. Start typing messages in the ComputerCraft terminal
2. Press Enter to send your message
3. The bot will respond with formatted text that wraps properly in the terminal
4. Type 'exit' to quit the program

## Project Structure

- `api/index.ts` - Express.js server with OpenAI integration
- `chat.lua` - ComputerCraft client implementation
- `package.json` - Node.js project configuration and dependencies
- `.env` - Environment variables configuration

## Dependencies

### Server

- express
- openai
- cors
- dotenv

### Client

- ComputerCraft HTTP API
- ComputerCraft Term API

## License

ISC

## Contributing

Feel free to submit issues and pull requests to improve the project.
