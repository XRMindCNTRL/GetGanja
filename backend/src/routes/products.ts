import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import { v4 as uuidv4 } from 'uuid';
import storageService from '../utils/storageService';

const router = Router();
const prisma = new PrismaClient();

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
  } catch (error) {
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
  } catch (error) {
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
  } catch (error) {
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
  } catch (error) {
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
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete product' });
  }
});

// Upload product image
router.post('/:id/upload-image', async (req, res) => {
  try {
    // Check if product exists
    const product = await prisma.product.findUnique({
      where: { id: req.params.id }
    });

    if (!product) {
      return res.status(404).json({ error: 'Product not found' });
    }

    // Check if file was uploaded
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    // Validate file type
    const allowedMimes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
    if (!allowedMimes.includes(req.file.mimetype)) {
      return res.status(400).json({ error: 'Invalid file type. Only JPEG, PNG, WebP, and GIF are allowed' });
    }

    // Upload to Azure Blob Storage
    const imageUrl = await storageService.uploadProductImage(req.file, req.params.id);

    // Update product with new image URL
    const updatedProduct = await prisma.product.update({
      where: { id: req.params.id },
      data: { imageUrl }
    });

    res.status(200).json({
      message: 'Image uploaded successfully',
      imageUrl,
      product: updatedProduct
    });
  } catch (error) {
    console.error('Error uploading image:', error);
    res.status(500).json({ error: 'Failed to upload image' });
  }
});

// Get product images (list all images for a product)
router.get('/:id/images', async (req, res) => {
  try {
    const product = await prisma.product.findUnique({
      where: { id: req.params.id },
      select: { id: true, imageUrl: true, name: true }
    });

    if (!product) {
      return res.status(404).json({ error: 'Product not found' });
    }

    res.json({
      productId: product.id,
      productName: product.name,
      imageUrl: product.imageUrl,
      uploadedAt: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch product images' });
  }
});

export default router;
