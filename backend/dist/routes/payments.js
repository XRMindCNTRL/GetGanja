"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const stripe_1 = __importDefault(require("stripe"));
const client_1 = require("@prisma/client");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
const stripe = new stripe_1.default(process.env.STRIPE_SECRET_KEY || '', {
    apiVersion: '2023-10-16',
});
// Create payment intent
router.post('/create-payment-intent', async (req, res) => {
    try {
        const { amount, currency, metadata, items, deliveryAddress, deliveryLat, deliveryLng, notes } = req.body;
        // Create order in database first
        const order = await prisma.order.create({
            data: {
                userId: req.user?.id, // From auth middleware
                totalAmount: amount / 100, // Convert back to dollars
                deliveryFee: 10, // Fixed delivery fee
                taxAmount: (amount / 100) * 0.08, // 8% tax
                finalAmount: amount / 100,
                deliveryAddress,
                deliveryLat,
                deliveryLng,
                notes,
                status: 'PENDING_PAYMENT',
                items: {
                    create: items.map((item) => ({
                        productId: item.productId,
                        quantity: item.quantity,
                        price: item.price,
                        total: item.price * item.quantity,
                    })),
                },
            },
        });
        // Create payment intent
        const paymentIntent = await stripe.paymentIntents.create({
            amount,
            currency: currency || 'usd',
            metadata: {
                ...metadata,
                orderId: order.id,
            },
        });
        res.json({
            clientSecret: paymentIntent.client_secret,
            orderId: order.id,
        });
    }
    catch (error) {
        console.error('Error creating payment intent:', error);
        res.status(500).json({ error: 'Failed to create payment intent' });
    }
});
// Webhook to handle payment success
router.post('/webhook', async (req, res) => {
    const sig = req.headers['stripe-signature'];
    const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;
    let event;
    try {
        event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
    }
    catch (err) {
        console.log(`Webhook signature verification failed.`, err.message);
        return res.status(400).send(`Webhook Error: ${err.message}`);
    }
    // Handle the event
    switch (event.type) {
        case 'payment_intent.succeeded':
            const paymentIntent = event.data.object;
            const orderId = paymentIntent.metadata.orderId;
            // Update order status
            await prisma.order.update({
                where: { id: orderId },
                data: { status: 'CONFIRMED' },
            });
            // Update product stock
            const order = await prisma.order.findUnique({
                where: { id: orderId },
                include: { items: true },
            });
            if (order) {
                for (const item of order.items) {
                    await prisma.product.update({
                        where: { id: item.productId },
                        data: { stock: { decrement: item.quantity } },
                    });
                }
            }
            break;
        default:
            console.log(`Unhandled event type ${event.type}`);
    }
    res.json({ received: true });
});
exports.default = router;
//# sourceMappingURL=payments.js.map