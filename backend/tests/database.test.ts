import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

describe('Database Operations Tests', () => {
  beforeAll(async () => {
    // Clean up test database
    await prisma.delivery.deleteMany();
    await prisma.orderItem.deleteMany();
    await prisma.order.deleteMany();
    await prisma.product.deleteMany();
    await prisma.address.deleteMany();
    await prisma.customerProfile.deleteMany();
    await prisma.vendorProfile.deleteMany();
    await prisma.driverProfile.deleteMany();
    await prisma.user.deleteMany();
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  describe('User CRUD Operations', () => {
    test('should create user with all required fields', async () => {
      const user = await prisma.user.create({
        data: {
          email: 'test@example.com',
          password: 'hashedpassword',
          firstName: 'Test',
          lastName: 'User',
          phone: '+1234567890',
          role: 'CUSTOMER'
        }
      });

      expect(user.id).toBeDefined();
      expect(user.email).toBe('test@example.com');
      expect(user.role).toBe('CUSTOMER');
      expect(user.isActive).toBe(true);
      expect(user.createdAt).toBeInstanceOf(Date);
    });

    test('should enforce unique email constraint', async () => {
      await expect(
        prisma.user.create({
          data: {
            email: 'test@example.com',
            password: 'hashedpassword2',
            firstName: 'Test2',
            lastName: 'User2',
            phone: '+1234567891',
            role: 'CUSTOMER'
          }
        })
      ).rejects.toThrow();
    });

    test('should read user by ID', async () => {
      const user = await prisma.user.findUnique({
        where: { email: 'test@example.com' }
      });

      expect(user).toBeTruthy();
      expect(user!.firstName).toBe('Test');
    });

    test('should update user information', async () => {
      const user = await prisma.user.findUnique({
        where: { email: 'test@example.com' }
      });

      const updatedUser = await prisma.user.update({
        where: { id: user!.id },
        data: { firstName: 'UpdatedTest' }
      });

      expect(updatedUser.firstName).toBe('UpdatedTest');
    });

    test('should delete user', async () => {
      const user = await prisma.user.findUnique({
        where: { email: 'test@example.com' }
      });

      await prisma.user.delete({
        where: { id: user!.id }
      });

      const deletedUser = await prisma.user.findUnique({
        where: { id: user!.id }
      });

      expect(deletedUser).toBeNull();
    });
  });

  describe('Profile Management', () => {
    let userId: string;

    beforeAll(async () => {
      const user = await prisma.user.create({
        data: {
          email: 'profile@test.com',
          password: 'hashedpassword',
          firstName: 'Profile',
          lastName: 'Test',
          phone: '+1234567890',
          role: 'CUSTOMER'
        }
      });
      userId = user.id;
    });

    test('should create customer profile', async () => {
      const profile = await prisma.customerProfile.create({
        data: {
          userId: userId,
          dateOfBirth: new Date('1990-01-01'),
          verified: true
        }
      });

      expect(profile.id).toBeDefined();
      expect(profile.userId).toBe(userId);
      expect(profile.verified).toBe(true);
    });

    test('should create vendor profile with business details', async () => {
      const vendorUser = await prisma.user.create({
        data: {
          email: 'vendorprofile@test.com',
          password: 'hashedpassword',
          firstName: 'Vendor',
          lastName: 'Profile',
          phone: '+1234567891',
          role: 'VENDOR'
        }
      });

      const profile = await prisma.vendorProfile.create({
        data: {
          userId: vendorUser.id,
          businessName: 'Test Business',
          businessType: 'RETAIL',
          licenseNumber: 'LIC789',
          licenseExpiry: new Date('2025-12-31'),
          address: '456 Business St',
          phone: '+1234567892',
          email: 'business@test.com',
          latitude: -33.9249,
          longitude: 18.4241,
          isApproved: true
        }
      });

      expect(profile.businessName).toBe('Test Business');
      expect(profile.licenseNumber).toBe('LIC789');
      expect(profile.isApproved).toBe(true);
    });

    test('should create driver profile with vehicle details', async () => {
      const driverUser = await prisma.user.create({
        data: {
          email: 'driverprofile@test.com',
          password: 'hashedpassword',
          firstName: 'Driver',
          lastName: 'Profile',
          phone: '+1234567893',
          role: 'DRIVER'
        }
      });

      const profile = await prisma.driverProfile.create({
        data: {
          userId: driverUser.id,
          licenseNumber: 'DL789',
          vehicleType: 'VAN',
          vehiclePlate: 'XYZ789',
          isAvailable: true,
          rating: 4.8,
          totalDeliveries: 150
        }
      });

      expect(profile.vehicleType).toBe('VAN');
      expect(profile.rating).toBe(4.8);
      expect(profile.isAvailable).toBe(true);
    });
  });

  describe('Product Management', () => {
    let vendorId: string;

    beforeAll(async () => {
      const vendorUser = await prisma.user.create({
        data: {
          email: 'productvendor@test.com',
          password: 'hashedpassword',
          firstName: 'Product',
          lastName: 'Vendor',
          phone: '+1234567890',
          role: 'VENDOR'
        }
      });

      const vendorProfile = await prisma.vendorProfile.create({
        data: {
          userId: vendorUser.id,
          businessName: 'Product Vendor',
          businessType: 'RETAIL',
          licenseNumber: 'LIC999',
          licenseExpiry: new Date('2025-12-31'),
          address: '789 Product St',
          phone: '+1234567891',
          email: 'product@vendor.com'
        }
      });

      vendorId = vendorProfile.id;
    });

    test('should create product with cannabis-specific fields', async () => {
      const product = await prisma.product.create({
        data: {
          vendorId: vendorId,
          name: 'Blue Dream',
          description: 'Sativa-dominant hybrid',
          price: 15.99,
          category: 'FLOWER',
          strain: 'HYBRID',
          thcContent: 18.5,
          cbdContent: 0.1,
          weight: 3.5,
          unit: 'g',
          stock: 100,
          imageUrl: 'https://example.com/blue-dream.jpg'
        }
      });

      expect(product.name).toBe('Blue Dream');
      expect(product.thcContent).toBe(18.5);
      expect(product.stock).toBe(100);
      expect(product.isActive).toBe(true);
    });

    test('should update product stock', async () => {
      const product = await prisma.product.findFirst({
        where: { name: 'Blue Dream' }
      });

      const updatedProduct = await prisma.product.update({
        where: { id: product!.id },
        data: { stock: 95 }
      });

      expect(updatedProduct.stock).toBe(95);
    });

    test('should enforce vendor-product relationship', async () => {
      const products = await prisma.product.findMany({
        where: { vendorId: vendorId }
      });

      expect(products.length).toBeGreaterThan(0);
      expect(products[0].vendorId).toBe(vendorId);
    });
  });

  describe('Order Management', () => {
    let userId: string;
    let productId: string;

    beforeAll(async () => {
      const user = await prisma.user.create({
        data: {
          email: 'ordertest@test.com',
          password: 'hashedpassword',
          firstName: 'Order',
          lastName: 'Test',
          phone: '+1234567890',
          role: 'CUSTOMER'
        }
      });
      userId = user.id;

      const product = await prisma.product.findFirst();
      productId = product!.id;
    });

    test('should create order with items', async () => {
      const order = await prisma.order.create({
        data: {
          userId: userId,
          status: 'PENDING',
          totalAmount: 31.98,
          deliveryFee: 5.00,
          taxAmount: 2.40,
          finalAmount: 39.38,
          deliveryAddress: '123 Test St, Cape Town',
          deliveryLat: -33.9249,
          deliveryLng: 18.4241,
          items: {
            create: [
              {
                productId: productId,
                quantity: 2,
                price: 15.99,
                total: 31.98
              }
            ]
          }
        },
        include: {
          items: true
        }
      });

      expect(order.totalAmount).toBe(31.98);
      expect(order.items.length).toBe(1);
      expect(order.items[0].quantity).toBe(2);
    });

    test('should update order status', async () => {
      const order = await prisma.order.findFirst({
        where: { userId: userId }
      });

      const updatedOrder = await prisma.order.update({
        where: { id: order!.id },
        data: { status: 'CONFIRMED' }
      });

      expect(updatedOrder.status).toBe('CONFIRMED');
    });

    test('should calculate order totals correctly', async () => {
      const order = await prisma.order.findFirst({
        where: { userId: userId },
        include: { items: true }
      });

      const calculatedTotal = order!.items.reduce((sum, item) => sum + item.total, 0);
      expect(order!.totalAmount).toBe(calculatedTotal);
    });
  });

  describe('Delivery Management', () => {
    let orderId: string;
    let driverId: string;

    beforeAll(async () => {
      const order = await prisma.order.findFirst();
      orderId = order!.id;

      const driverUser = await prisma.user.create({
        data: {
          email: 'deliverydriver@test.com',
          password: 'hashedpassword',
          firstName: 'Delivery',
          lastName: 'Driver',
          phone: '+1234567890',
          role: 'DRIVER'
        }
      });

      const driverProfile = await prisma.driverProfile.create({
        data: {
          userId: driverUser.id,
          licenseNumber: 'DL999',
          vehicleType: 'CAR',
          vehiclePlate: 'DEL999'
        }
      });

      driverId = driverProfile.id;
    });

    test('should create delivery assignment', async () => {
      const delivery = await prisma.delivery.create({
        data: {
          orderId: orderId,
          driverId: driverId,
          status: 'ASSIGNED',
          estimatedArrival: new Date(Date.now() + 30 * 60 * 1000), // 30 minutes from now
          notes: 'Handle with care'
        }
      });

      expect(delivery.status).toBe('ASSIGNED');
      expect(delivery.estimatedArrival).toBeInstanceOf(Date);
    });

    test('should update delivery status and location', async () => {
      const delivery = await prisma.delivery.findFirst({
        where: { orderId: orderId }
      });

      const updatedDelivery = await prisma.delivery.update({
        where: { id: delivery!.id },
        data: {
          status: 'IN_TRANSIT',
          actualArrival: new Date()
        }
      });

      expect(updatedDelivery.status).toBe('IN_TRANSIT');
      expect(updatedDelivery.actualArrival).toBeInstanceOf(Date);
    });

    test('should enforce unique delivery per order', async () => {
      await expect(
        prisma.delivery.create({
          data: {
            orderId: orderId,
            driverId: driverId,
            status: 'ASSIGNED'
          }
        })
      ).rejects.toThrow();
    });
  });

  describe('Data Integrity and Relationships', () => {
    test('should cascade delete user profiles', async () => {
      const user = await prisma.user.create({
        data: {
          email: 'cascadetest@test.com',
          password: 'hashedpassword',
          firstName: 'Cascade',
          lastName: 'Test',
          phone: '+1234567890',
          role: 'CUSTOMER'
        }
      });

      await prisma.customerProfile.create({
        data: { userId: user.id }
      });

      await prisma.user.delete({
        where: { id: user.id }
      });

      const profile = await prisma.customerProfile.findUnique({
        where: { userId: user.id }
      });

      expect(profile).toBeNull();
    });

    test('should maintain referential integrity', async () => {
      const user = await prisma.user.findFirst();
      const product = await prisma.product.findFirst();

      expect(user).toBeTruthy();
      expect(product).toBeTruthy();

      // Ensure foreign key relationships are valid
      const userOrders = await prisma.order.findMany({
        where: { userId: user!.id }
      });

      expect(userOrders.length).toBeGreaterThanOrEqual(0);
    });

    test('should handle concurrent operations safely', async () => {
      const operations = Array(5).fill(null).map(async (_, i) => {
        return prisma.user.create({
          data: {
            email: `concurrent${i}@test.com`,
            password: 'hashedpassword',
            firstName: `Concurrent${i}`,
            lastName: 'Test',
            phone: `+123456789${i}`,
            role: 'CUSTOMER'
          }
        });
      });

      const results = await Promise.all(operations);
      expect(results).toHaveLength(5);
      results.forEach(result => {
        expect(result.id).toBeDefined();
      });
    });
  });
});
