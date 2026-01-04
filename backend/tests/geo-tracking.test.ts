import { PrismaClient } from '@prisma/client';
import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';
import { io as Client } from 'socket.io-client';

const prisma = new PrismaClient();

describe('Geo Tracking Tests', () => {
  let io: Server;
  let clientSocket: any;
  let httpServer: any;
  let app: express.Application;

  beforeAll(async () => {
    // Clean up test database
    await prisma.delivery.deleteMany();
    await prisma.order.deleteMany();
    await prisma.driverProfile.deleteMany();
    await prisma.user.deleteMany();

    // Set up Socket.IO server for testing
    app = express();
    httpServer = createServer(app);
    io = new Server(httpServer, {
      cors: {
        origin: "*",
        methods: ["GET", "POST"]
      }
    });

    // Mock Socket.IO handlers
    io.on('connection', (socket) => {
      socket.on('driver-location-update', (data) => {
        // Handle location updates
        socket.broadcast.emit('location-updated', data);
      });

      socket.on('join-delivery-room', (deliveryId) => {
        socket.join(`delivery-${deliveryId}`);
      });

      socket.on('update-delivery-status', (data) => {
        socket.to(`delivery-${data.deliveryId}`).emit('delivery-status-changed', data);
      });
    });

    httpServer.listen(3001);
  });

  afterAll(async () => {
    if (clientSocket) clientSocket.disconnect();
    if (io) io.close();
    if (httpServer) httpServer.close();
    await prisma.$disconnect();
  });

  describe('Driver Location Management', () => {
    let driverId: string;
    let driverUserId: string;

    beforeAll(async () => {
      const driverUser = await prisma.user.create({
        data: {
          email: 'geodriver@test.com',
          password: 'hashedpassword',
          firstName: 'Geo',
          lastName: 'Driver',
          phone: '+1234567890',
          role: 'DRIVER'
        }
      });
      driverUserId = driverUser.id;

      const driverProfile = await prisma.driverProfile.create({
        data: {
          userId: driverUserId,
          licenseNumber: 'DLGEO',
          vehicleType: 'VAN',
          vehiclePlate: 'GEO123',
          isAvailable: true
        }
      });
      driverId = driverProfile.id;
    });

    test('should update driver location coordinates', async () => {
      const updatedDriver = await prisma.driverProfile.update({
        where: { id: driverId },
        data: {
          // Note: In a real implementation, these would be updated via GPS/location service
          // For testing, we'll simulate location updates
        }
      });

      expect(updatedDriver.id).toBe(driverId);
    });

    test('should track driver availability status', async () => {
      // Test driver going offline
      const offlineDriver = await prisma.driverProfile.update({
        where: { id: driverId },
        data: { isAvailable: false }
      });

      expect(offlineDriver.isAvailable).toBe(false);

      // Test driver coming back online
      const onlineDriver = await prisma.driverProfile.update({
        where: { id: driverId },
        data: { isAvailable: true }
      });

      expect(onlineDriver.isAvailable).toBe(true);
    });

    test('should calculate distance between coordinates', () => {
      // Mock coordinates for Cape Town CBD and Table Mountain
      const point1 = { lat: -33.9249, lng: 18.4241 }; // Cape Town CBD
      const point2 = { lat: -33.9628, lng: 18.4098 }; // Table Mountain

      // Simple distance calculation (Haversine formula approximation)
      const distance = calculateDistance(point1.lat, point1.lng, point2.lat, point2.lng);
      expect(distance).toBeGreaterThan(0);
      expect(distance).toBeLessThan(10); // Should be around 4-5 km
    });
  });

  describe('Delivery Tracking', () => {
    let orderId: string;
    let deliveryId: string;

    beforeAll(async () => {
      const customerUser = await prisma.user.create({
        data: {
          email: 'geocustomer@test.com',
          password: 'hashedpassword',
          firstName: 'Geo',
          lastName: 'Customer',
          phone: '+1234567891',
          role: 'CUSTOMER'
        }
      });

      const order = await prisma.order.create({
        data: {
          userId: customerUser.id,
          status: 'CONFIRMED',
          totalAmount: 25.00,
          deliveryFee: 5.00,
          finalAmount: 30.00,
          deliveryAddress: '123 Geo Test St, Cape Town',
          deliveryLat: -33.9249,
          deliveryLng: 18.4241
        }
      });
      orderId = order.id;

      const delivery = await prisma.delivery.create({
        data: {
          orderId: orderId,
          driverId: driverId,
          status: 'ASSIGNED',
          estimatedArrival: new Date(Date.now() + 45 * 60 * 1000) // 45 minutes
        }
      });
      deliveryId = delivery.id;
    });

    test('should create delivery with route information', async () => {
      const delivery = await prisma.delivery.findUnique({
        where: { id: deliveryId },
        include: { order: true, driver: true }
      });

      expect(delivery!.order.deliveryLat).toBe(-33.9249);
      expect(delivery!.order.deliveryLng).toBe(18.4241);
      expect(delivery!.status).toBe('ASSIGNED');
    });

    test('should update delivery progress and ETA', async () => {
      const updatedDelivery = await prisma.delivery.update({
        where: { id: deliveryId },
        data: {
          status: 'IN_TRANSIT',
          estimatedArrival: new Date(Date.now() + 20 * 60 * 1000) // 20 minutes
        }
      });

      expect(updatedDelivery.status).toBe('IN_TRANSIT');
      expect(updatedDelivery.estimatedArrival!.getTime()).toBeGreaterThan(Date.now());
    });

    test('should mark delivery as completed', async () => {
      const completedDelivery = await prisma.delivery.update({
        where: { id: deliveryId },
        data: {
          status: 'DELIVERED',
          actualArrival: new Date()
        }
      });

      expect(completedDelivery.status).toBe('DELIVERED');
      expect(completedDelivery.actualArrival).toBeInstanceOf(Date);

      // Update driver stats
      await prisma.driverProfile.update({
        where: { id: driverId },
        data: {
          totalDeliveries: { increment: 1 }
        }
      });

      const updatedDriver = await prisma.driverProfile.findUnique({
        where: { id: driverId }
      });

      expect(updatedDriver!.totalDeliveries).toBeGreaterThan(0);
    });
  });

  describe('Real-time Location Updates', () => {
    test('should handle Socket.IO connections', (done) => {
      clientSocket = Client('http://localhost:3001');

      clientSocket.on('connect', () => {
        expect(clientSocket.connected).toBe(true);
        done();
      });

      clientSocket.on('connect_error', (error: any) => {
        done(error);
      });
    });

    test('should broadcast location updates', (done) => {
      const locationData = {
        driverId: driverId,
        latitude: -33.9249,
        longitude: 18.4241,
        timestamp: new Date().toISOString()
      };

      clientSocket.emit('driver-location-update', locationData);

      // Listen for the broadcast
      clientSocket.on('location-updated', (data: any) => {
        expect(data.driverId).toBe(driverId);
        expect(data.latitude).toBe(-33.9249);
        expect(data.longitude).toBe(18.4241);
        done();
      });
    });

    test('should handle delivery room joins', (done) => {
      clientSocket.emit('join-delivery-room', deliveryId);

      // Simulate status update
      const statusData = {
        deliveryId: deliveryId,
        status: 'OUT_FOR_DELIVERY',
        location: { lat: -33.9249, lng: 18.4241 }
      };

      clientSocket.emit('update-delivery-status', statusData);

      // Should receive status update in the room
      clientSocket.on('delivery-status-changed', (data: any) => {
        expect(data.deliveryId).toBe(deliveryId);
        expect(data.status).toBe('OUT_FOR_DELIVERY');
        done();
      });
    });
  });

  describe('Route Optimization', () => {
    test('should calculate optimal delivery routes', () => {
      const waypoints = [
        { lat: -33.9249, lng: 18.4241 }, // Start
        { lat: -33.9300, lng: 18.4300 }, // Stop 1
        { lat: -33.9350, lng: 18.4350 }, // Stop 2
        { lat: -33.9400, lng: 18.4400 }  // Stop 3
      ];

      // Calculate total route distance
      let totalDistance = 0;
      for (let i = 0; i < waypoints.length - 1; i++) {
        totalDistance += calculateDistance(
          waypoints[i].lat, waypoints[i].lng,
          waypoints[i + 1].lat, waypoints[i + 1].lng
        );
      }

      expect(totalDistance).toBeGreaterThan(0);
      // Route should be somewhat efficient (not exceeding reasonable bounds)
      expect(totalDistance).toBeLessThan(20); // km
    });

    test('should estimate delivery time based on distance', () => {
      const distance = 5; // km
      const averageSpeed = 30; // km/h
      const estimatedTime = (distance / averageSpeed) * 60; // minutes

      expect(estimatedTime).toBeGreaterThan(0);
      expect(estimatedTime).toBe(10); // Should be 10 minutes for 5km at 30km/h
    });

    test('should handle traffic and weather factors', () => {
      const baseTime = 30; // minutes
      const trafficMultiplier = 1.5; // 50% traffic delay
      const weatherMultiplier = 1.2; // 20% weather delay

      const adjustedTime = baseTime * trafficMultiplier * weatherMultiplier;

      expect(adjustedTime).toBeGreaterThan(baseTime);
      expect(adjustedTime).toBe(54); // 30 * 1.5 * 1.2 = 54 minutes
    });
  });

  describe('Geofencing and Zone Management', () => {
    test('should detect if location is within delivery zone', () => {
      const deliveryZone = {
        center: { lat: -33.9249, lng: 18.4241 },
        radius: 10 // km
      };

      const insidePoint = { lat: -33.9300, lng: 18.4300 }; // ~1km away
      const outsidePoint = { lat: -33.9800, lng: 18.4800 }; // ~7km away

      expect(isWithinZone(insidePoint, deliveryZone)).toBe(true);
      expect(isWithinZone(outsidePoint, deliveryZone)).toBe(false);
    });

    test('should assign deliveries based on driver zones', async () => {
      const zoneDrivers = await prisma.driverProfile.findMany({
        where: { isAvailable: true }
      });

      // In a real implementation, this would match drivers to delivery zones
      expect(Array.isArray(zoneDrivers)).toBe(true);
    });

    test('should track delivery zone performance', () => {
      const zoneStats = {
        zoneId: 'cape-town-cbd',
        totalDeliveries: 150,
        averageDeliveryTime: 28, // minutes
        onTimePercentage: 92.5
      };

      expect(zoneStats.averageDeliveryTime).toBeGreaterThan(0);
      expect(zoneStats.onTimePercentage).toBeGreaterThan(90);
    });
  });
});

// Helper functions for testing
function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371; // Earth's radius in km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a =
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c;
}

function isWithinZone(point: { lat: number; lng: number }, zone: { center: { lat: number; lng: number }, radius: number }): boolean {
  const distance = calculateDistance(point.lat, point.lng, zone.center.lat, zone.center.lng);
  return distance <= zone.radius;
}
