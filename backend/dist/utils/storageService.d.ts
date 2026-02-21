declare class StorageService {
    private blobServiceClient;
    private containerClient;
    constructor();
    /**
     * Initialize storage container if it doesn't exist
     */
    initializeContainer(): Promise<void>;
    /**
     * Upload a file to blob storage
     * @param file - File from multer
     * @param productId - Product ID for organizing blobs
     * @returns Promise with blob URL
     */
    uploadProductImage(file: Express.Multer.File, productId: string): Promise<string>;
    /**
     * Generate a SAS URL for accessing a blob
     * @param blobName - Name of the blob
     * @param expiryHours - How many hours the URL should be valid (default 24)
     * @returns SAS URL or public blob URL
     */
    generateSasUrl(blobName: string, expiryHours?: number): Promise<string>;
    /**
     * Delete a blob from storage
     * @param blobName - Name of the blob to delete
     */
    deleteBlob(blobName: string): Promise<void>;
    /**
     * Get blob metadata
     * @param blobName - Name of the blob
     */
    getBlobMetadata(blobName: string): Promise<any>;
    /**
     * Check if storage is configured
     */
    isConfigured(): boolean;
}
declare const _default: StorageService;
export default _default;
//# sourceMappingURL=storageService.d.ts.map