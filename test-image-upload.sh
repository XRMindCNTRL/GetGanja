#!/bin/bash

# Test Image Upload API Script
# This script tests the blob storage image upload endpoint

API_URL="${1:-http://localhost:3001}"
PRODUCT_ID="${2:-1}"
IMAGE_PATH="${3:-./test-image.jpg}"

echo "==================================="
echo "Testing Image Upload Endpoint"
echo "==================================="
echo ""
echo "API URL: $API_URL"
echo "Product ID: $PRODUCT_ID"
echo "Image Path: $IMAGE_PATH"
echo ""

# Check if image file exists
if [ ! -f "$IMAGE_PATH" ]; then
    echo "❌ Error: Image file not found at $IMAGE_PATH"
    echo ""
    echo "Creating a test image (1x1 pixel JPEG)..."
    
    # Create a minimal valid JPEG
    printf '\xFF\xD8\xFF\xE0\x00\x10JFIF' > "$IMAGE_PATH"
    printf '\x00\x01\x01\x00\x00\x01\x00\x01\x00\x00\xFF\xDB\x00C\x00\x08\x06\x06\x07' >> "$IMAGE_PATH"
    printf '\x06\x05\x08\x07\x07\x07\t\t\x08\n\x0c\x14\r\x0c\x0b\x0b\x0c\x19\x12\x13' >> "$IMAGE_PATH"
    printf '\x0f\x14\x1d\x1a\x1f\x1e\x1d\x1a\x1c\x1c $.\' ",#\x1c\x1c(7),01444\x1f' >> "$IMAGE_PATH"
    printf "'9=82<.342\xFF\xC0\x00\x0B\x01\x01\x01\x11\x00\x02\x11\x01\x03\x11\x01\xFF" >> "$IMAGE_PATH"
    printf '\xC4\x00\x1F\x00\x00\x01\x05\x01\x01\x01\x01\x01\x01\x00\x00\x00\x00\x00' >> "$IMAGE_PATH"
    printf '\x00\x00\x00\x01\x02\x03\x04\x05\x06\x07\x08\t\n\x0B\xFF\xC4\x00\xB5\x10' >> "$IMAGE_PATH"
    printf '\x00\x02\x01\x03\x03\x02\x04\x03\x05\x05\x04\x04\x00\x00\x01}\x01\x02\x03' >> "$IMAGE_PATH"
    printf '\x00\x04\x11\x05\x12!1A\x06\x13Qa\x07"q\x142\x81\x91\xA1\x08#B\xB1\xC1\x15' >> "$IMAGE_PATH"
    printf '\x52\xD1\xF0$3br\x82\t\n\x16\x17\x18\x19\x1A%&\'()*456789:CDEFGHIJSTUVWXYZcdefghijstuvwxyz\x83\x84\x85\x86\x87' >> "$IMAGE_PATH"
    printf '\x88\x89\x8A\x92\x93\x94\x95\x96\x97\x98\x99\x9A\xA2\xA3\xA4\xA5\xA6\xA7' >> "$IMAGE_PATH"
    printf '\xA8\xA9\xAA\xB2\xB3\xB4\xB5\xB6\xB7\xB8\xB9\xBA\xC2\xC3\xC4\xC5\xC6\xC7' >> "$IMAGE_PATH"
    printf '\xC8\xC9\xCA\xD2\xD3\xD4\xD5\xD6\xD7\xD8\xD9\xDA\xE1\xE2\xE3\xE4\xE5\xE6' >> "$IMAGE_PATH"
    printf '\xE7\xE8\xE9\xEA\xF1\xF2\xF3\xF4\xF5\xF6\xF7\xF8\xF9\xFA\xFF\xDA\x08\x01' >> "$IMAGE_PATH"
    printf '\x01\x00\x00?\x00\xFD\xE4\xFF\xD9' >> "$IMAGE_PATH"
    
    echo "✅ Test image created: $IMAGE_PATH (size: $(stat -f%z "$IMAGE_PATH" 2>/dev/null || stat -c%s "$IMAGE_PATH" 2>/dev/null) bytes)"
fi

# Test 1: Check if server is running
echo ""
echo "Test 1: Checking if server is running..."
if curl -s "$API_URL/health" > /dev/null 2>&1 || curl -s "$API_URL/" > /dev/null 2>&1; then
    echo "✅ Server is running"
else
    echo "⚠️  Warning: Could not reach server at $API_URL"
    echo "   Make sure the backend is running: npm run dev"
fi

# Test 2: Upload image
echo ""
echo "Test 2: Testing image upload..."
echo "Uploading image to: POST $API_URL/products/$PRODUCT_ID/upload-image"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  -F "image=@$IMAGE_PATH" \
  "$API_URL/products/$PRODUCT_ID/upload-image" \
  -H "Accept: application/json")

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | head -n -1)

echo "HTTP Status Code: $HTTP_CODE"
echo ""
echo "Response Body:"
echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
echo ""

if [[ "$HTTP_CODE" == "200" ]]; then
    echo "✅ Upload successful!"
    echo ""
    echo "Extracted fields:"
    echo "  - Image URL: $(echo "$BODY" | jq -r '.imageUrl' 2>/dev/null || echo 'N/A')"
    echo "  - Upload Time: $(echo "$BODY" | jq -r '.uploadedAt' 2>/dev/null || echo 'N/A')"
    echo ""
    echo "Test with SAS URL:"
    SAS_URL=$(echo "$BODY" | jq -r '.imageUrl' 2>/dev/null)
    if [[ -n "$SAS_URL" && "$SAS_URL" != "null" ]]; then
        echo "Attempting to download image via SAS URL..."
        if curl -s -o /tmp/downloaded-image.jpg -w "HTTP %{http_code}" "$SAS_URL"; then
            echo ""
            echo "✅ SAS URL is accessible!"
        else
            echo ""
            echo "⚠️  Warning: SAS URL may not be accessible yet"
        fi
    fi
elif [[ "$HTTP_CODE" == "400" ]]; then
    echo "❌ Client error (400): Check image format and file size"
elif [[ "$HTTP_CODE" == "404" ]]; then
    echo "❌ Not found (404): Product $PRODUCT_ID does not exist"
elif [[ "$HTTP_CODE" == "500" ]]; then
    echo "❌ Server error (500): Check Azure Storage configuration"
else
    echo "⚠️  Unexpected status code: $HTTP_CODE"
fi

echo ""
echo "==================================="
echo "Test Complete"
echo "==================================="
echo ""
echo "Next Steps:"
echo "1. Verify the image appears in Azure Blob Storage"
echo "2. Check that Product.imageUrl is updated in database"
echo "3. Verify the SAS URL is valid and image is accessible"
echo ""
