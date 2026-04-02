import express from 'express';
import cors from 'cors';
import { WebSocketServer, WebSocket } from 'ws';
import http from 'http';

const app = express();
const server = http.createServer(app);
const wss = new WebSocketServer({ server });

app.use(cors());
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
  });
});

// Command queue endpoints
app.get('/api/queue', (req, res) => {
  // TODO: Return current command queue
  res.json([]);
});

// File system endpoints
app.get('/api/files/*', (req, res) => {
  // TODO: Return EAA repository files
  res.json([]);
});

// Harness endpoints
app.get('/api/harness/traces', (req, res) => {
  // TODO: Return harness traces
  res.json([]);
});

app.get('/api/harness/outcomes', (req, res) => {
  // TODO: Return harness outcomes
  res.json([]);
});

// WebSocket connection handling
wss.on('connection', (ws: WebSocket) => {
  console.log('Client connected');

  ws.on('message', (message) => {
    const data = JSON.parse(message.toString());

    switch (data.type) {
      case 'execute_command':
        // TODO: Execute command and send updates
        ws.send(JSON.stringify({
          type: 'command_update',
          commandId: data.commandId,
          status: 'executing',
        }));
        break;
      case 'subscribe_trace':
        // TODO: Subscribe to trace updates
        break;
    }
  });

  ws.on('close', () => {
    console.log('Client disconnected');
  });
});

const PORT = process.env.PORT || 5174;

server.listen(PORT, () => {
  console.log(`Backend server running on port ${PORT}`);
  console.log(`WebSocket server running on ws://localhost:${PORT}`);
});
