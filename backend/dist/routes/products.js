"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
// Get all products
router.get('/', async (req, res) => {
    try {
        const products = await prisma.product.findMany({
            where: { isActive: true },
            include: {
                vendor: {
                    select: {
                        businessName: true,
                        latitude: true,
                        longitude: true
                    }
                }
            }
        });
        res.json(products);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch products' });
    }
});
// Get product by ID
router.get('/:id', async (req, res) => {
    try {
        const product = await prisma.product.findUnique({
            where: { id: req.params.id },
            include: {
                vendor: {
                    select: {
                        businessName: true,
                        latitude: true,
                        longitude: true
                    }
                }
            }
        });
        if (!product) {
            return res.status(404).json({ error: 'Product not found' });
        }
        res.json(product);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch product' });
    }
});
// Create product (vendor only)
router.post('/', async (req, res) => {
    try {
        const { vendorId, name, description, price, category, strain, thcContent, cbdContent, weight, unit, stock, imageUrl } = req.body;
        const product = await prisma.product.create({
            data: {
                vendorId,
                name,
                description,
                price,
                category,
                strain,
                thcContent,
                cbdContent,
                weight,
                unit,
                stock,
                imageUrl
            }
        });
        res.status(201).json(product);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to create product' });
    }
});
// Update product (vendor only)
router.put('/:id', async (req, res) => {
    try {
        const product = await prisma.product.update({
            where: { id: req.params.id },
            data: req.body
        });
        res.json(product);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to update product' });
    }
});
// Delete product (vendor only)
router.delete('/:id', async (req, res) => {
    try {
        await prisma.product.update({
            where: { id: req.params.id },
            data: { isActive: false }
        });
        res.json({ message: 'Product deactivated' });
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to delete product' });
    }
});
exports.default = router;
//# sourceMappingURL=products.js.map