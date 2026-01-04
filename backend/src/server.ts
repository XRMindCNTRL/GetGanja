import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import { createServer } from 'http';
import { Server } from 'socket.io';
import authRoutes from './routes/auth';
import productRoutes from './routes/products';
import orderRoutes from './routes/orders';
import paymentRoutes from './routes/payments';

// Load environment variables
dotenv.config();

const app = express();
const server = createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.FRONTEND_URL || "http://localhost:3000",
    methods: ["GET", "POST"]
  }
});

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.FRONTEND_URL || "http://localhost:3000",
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use(limiter);

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Root route - serve landing page
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Cannabis Delivery Platform</title>
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                margin: 0;
                padding: 0;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            .container {
                text-align: center;
                max-width: 800px;
                padding: 2rem;
            }
            h1 {
                font-size: 3rem;
                margin-bottom: 1rem;
                text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
            }
            p {
                font-size: 1.2rem;
                margin-bottom: 2rem;
                opacity: 0.9;
            }
            .apps {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                gap: 1rem;
                margin-top: 2rem;
            }
            .app-card {
                background: rgba(255,255,255,0.1);
                padding: 1.5rem;
                border-radius: 10px;
                backdrop-filter: blur(10px);
                border: 1px solid rgba(255,255,255,0.2);
                transition: transform 0.3s ease;
            }
            .app-card:hover {
                transform: translateY(-5px);
            }
            .app-card h3 {
                margin-top: 0;
                color: #ffd700;
            }
            .status {
                display: inline-block;
                padding: 0.5rem 1rem;
                background: #28a745;
                color: white;
                border-radius: 20px;
                font-size: 0.9rem;
                margin-top: 1rem;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🌿 Cannabis Delivery Platform</h1>
            <p>South Africa's premier cannabis delivery service with real-time tracking, compliance controls, and age verification.</p>

            <div class="apps">
                <div class="app-card">
                    <h3>🛒 Customer App</h3>
                    <p>Browse products, place orders, and track deliveries in real-time.</p>
                    <span class="status">Coming Soon</span>
                </div>
                <div class="app-card">
                    <h3>🏪 Vendor Dashboard</h3>
                    <p>Manage inventory, process orders, and oversee operations.</p>
                    <span class="status">Coming Soon</span>
                </div>
                <div class="app-card">
                    <h3>🚚 Driver App</h3>
                    <p>Navigate deliveries and provide real-time location updates.</p>
                    <span class="status">Coming Soon</span>
                </div>
                <div class="app-card">
                    <h3>⚙️ Admin Panel</h3>
                    <p>System oversight, compliance monitoring, and analytics.</p>
                    <span class="status">Coming Soon</span>
                </div>
            </div>

            <p style="margin-top: 3rem; font-size: 1rem; opacity: 0.8;">
                Powered by Azure • Built for South Africa 🇿🇦
            </p>
        </div>
    </body>
    </html>
  `);
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Auth routes
app.use('/auth', authRoutes);

// Product routes
app.use('/products', productRoutes);

// Order routes
app.use('/orders', orderRoutes);

// Payment routes
app.use('/payments', paymentRoutes);

// Socket.io for real-time tracking
io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);

  socket.on('join-delivery', (deliveryId: string) => {
    socket.join(`delivery-${deliveryId}`);
  });

  socket.on('update-location', (data: { deliveryId: string; location: { lat: number; lng: number } }) => {
    socket.to(`delivery-${data.deliveryId}`).emit('location-update', data.location);
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });
});

const PORT = process.env.PORT || 5000;

server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

export default app;
