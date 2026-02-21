"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const storage_blob_1 = require("@azure/storage-blob");
const uuid_1 = require("uuid");
const path_1 = __importDefault(require("path"));
const connectionString = process.env.AZURE_STORAGE_CONNECTION_STRING;
const containerName = 'product-images';
if (!connectionString) {
    console.warn('AZURE_STORAGE_CONNECTION_STRING is not configured. Blob storage uploads will fail.');
}
class StorageService {
    constructor() {
        this.blobServiceClient = null;
        this.containerClient = null;
        if (connectionString) {
            this.blobServiceClient = storage_blob_1.BlobServiceClient.fromConnectionString(connectionString);
            this.containerClient = this.blobServiceClient.getContainerClient(containerName);
        }
    }
    /**
     * Initialize storage container if it doesn't exist
     */
    async initializeContainer() {
        if (!this.containerClient) {
            console.warn('Storage service not initialized. Skipping container initialization.');
            return;
        }
        try {
            const exists = await this.containerClient.exists();
            if (!exists) {
                await this.containerClient.create({ access: 'blob' });
                console.log(`Container '${containerName}' created successfully.`);
            }
            else {
                console.log(`Container '${containerName}' already exists.`);
            }
        }
        catch (error) {
            console.error('Error initializing container:', error);
            throw new Error('Failed to initialize blob storage container');
        }
    }
    /**
     * Upload a file to blob storage
     * @param file - File from multer
     * @param productId - Product ID for organizing blobs
     * @returns Promise with blob URL
     */
    async uploadProductImage(file, productId) {
        if (!this.containerClient) {
            throw new Error('Storage service not initialized');
        }
        try {
            // Generate unique blob name
            const fileName = `${productId}/${(0, uuid_1.v4)()}${path_1.default.extname(file.originalname)}`;
            const blockBlobClient = this.containerClient.getBlockBlobClient(fileName);
            // Upload file
            await blockBlobClient.upload(file.buffer, file.size, {
                blobHTTPHeaders: {
                    blobContentType: file.mimetype,
                },
            });
            // Generate SAS URL for public access (24 hour expiry)
            const sasUrl = await this.generateSasUrl(fileName);
            return sasUrl;
        }
        catch (error) {
            console.error('Error uploading blob:', error);
            throw new Error('Failed to upload image to blob storage');
        }
    }
    /**
     * Generate a SAS URL for accessing a blob
     * @param blobName - Name of the blob
     * @param expiryHours - How many hours the URL should be valid (default 24)
     * @returns SAS URL or public blob URL
     */
    async generateSasUrl(blobName, expiryHours = 24) {
        if (!this.containerClient) {
            throw new Error('Storage service not configured');
        }
        try {
            const blockBlobClient = this.containerClient.getBlockBlobClient(blobName);
            // Set expiry time
            const expiresOn = new Date();
            expiresOn.setHours(expiresOn.getHours() + expiryHours);
            // Create SAS permissions (read-only)
            const permissions = new storage_blob_1.BlobSASPermissions();
            permissions.read = true;
            // Generate SAS URL using BlobClient's generateSasUrl method
            const sasUrl = blockBlobClient.generateSasUrl({
                permissions,
                expiresOn,
            });
            return sasUrl;
        }
        catch (error) {
            console.error('Error generating SAS URL:', error);
            // Fallback to public blob URL if SAS generation fails
            const match = connectionString?.match(/AccountName=([^;]+)/);
            const accountName = match ? match[1] : '';
            if (accountName) {
                return `https://${accountName}.blob.core.windows.net/${containerName}/${blobName}`;
            }
            throw new Error('Failed to generate blob URL');
        }
    }
    /**
     * Delete a blob from storage
     * @param blobName - Name of the blob to delete
     */
    async deleteBlob(blobName) {
        if (!this.containerClient) {
            throw new Error('Storage service not initialized');
        }
        try {
            const blockBlobClient = this.containerClient.getBlockBlobClient(blobName);
            await blockBlobClient.delete();
            console.log(`Blob '${blobName}' deleted successfully.`);
        }
        catch (error) {
            console.error('Error deleting blob:', error);
            throw new Error('Failed to delete blob from storage');
        }
    }
    /**
     * Get blob metadata
     * @param blobName - Name of the blob
     */
    async getBlobMetadata(blobName) {
        if (!this.containerClient) {
            throw new Error('Storage service not initialized');
        }
        try {
            const blockBlobClient = this.containerClient.getBlockBlobClient(blobName);
            const properties = await blockBlobClient.getProperties();
            return properties;
        }
        catch (error) {
            console.error('Error getting blob metadata:', error);
            throw new Error('Failed to get blob metadata');
        }
    }
    /**
     * Check if storage is configured
     */
    isConfigured() {
        return !!this.blobServiceClient && !!this.containerClient;
    }
}
exports.default = new StorageService();
//# sourceMappingURL=storageService.js.map