import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';

const ProductDetail = ({ addToCart }) => {
  const { id } = useParams();
  const [product, setProduct] = useState(null);
  const [loading, setLoading] = useState(true);
  const [quantity, setQuantity] = useState(1);

  // Mock product data - replace with API call
  useEffect(() => {
    const mockProduct = {
      id: parseInt(id),
      name: 'Premium Cannabis Flower',
      category: 'Flower',
      price: 45.99,
      image: '/api/placeholder/400/400',
      description: 'High-quality cannabis flower with THC content of 22%. Grown organically with no pesticides or chemicals.',
      thc: '22%',
      cbd: '1%',
      strain: 'Indica Dominant',
      effects: ['Relaxation', 'Pain Relief', 'Sleep Aid'],
      flavors: ['Earthy', 'Pine', 'Sweet'],
      reviews: [
        { id: 1, user: 'John D.', rating: 5, comment: 'Excellent quality and fast delivery!' },
        { id: 2, user: 'Sarah M.', rating: 4, comment: 'Great product, will order again.' }
      ]
    };

    setTimeout(() => {
      setProduct(mockProduct);
      setLoading(false);
    }, 1000);
  }, [id]);

  const handleQuantityChange = (e) => {
    const value = parseInt(e.target.value);
    if (value > 0 && value <= 10) {
      setQuantity(value);
    }
  };

  const handleAddToCart = () => {
    for (let i = 0; i < quantity; i++) {
      addToCart(product);
    }
    alert(`Added ${quantity} ${product.name} to cart`);
  };

  if (loading) {
    return (
      <div className="product-detail-page">
        <div className="loading">Loading product details...</div>
      </div>
    );
  }

  if (!product) {
    return (
      <div className="product-detail-page">
        <div className="error">Product not found</div>
      </div>
    );
  }

  return (
    <div className="product-detail-page">
      <div className="product-detail-container">
        <div className="product-image-section">
          <img src={product.image} alt={product.name} className="product-main-image" />
        </div>

        <div className="product-info-section">
          <div className="product-header">
            <h1>{product.name}</h1>
            <p className="category">{product.category}</p>
          </div>

          <div className="product-price">
            <span className="price">${product.price}</span>
          </div>

          <div className="product-description">
            <h3>Description</h3>
            <p>{product.description}</p>
          </div>

          <div className="product-specs">
            <h3>Specifications</h3>
            <div className="specs-grid">
              <div className="spec-item">
                <span className="spec-label">THC:</span>
                <span className="spec-value">{product.thc}</span>
              </div>
              <div className="spec-item">
                <span className="spec-label">CBD:</span>
                <span className="spec-value">{product.cbd}</span>
              </div>
              <div className="spec-item">
                <span className="spec-label">Strain:</span>
                <span className="spec-value">{product.strain}</span>
              </div>
            </div>
          </div>

          <div className="product-effects">
            <h3>Effects</h3>
            <div className="effects-tags">
              {product.effects.map((effect, index) => (
                <span key={index} className="effect-tag">{effect}</span>
              ))}
            </div>
          </div>

          <div className="product-flavors">
            <h3>Flavors</h3>
            <div className="flavor-tags">
              {product.flavors.map((flavor, index) => (
                <span key={index} className="flavor-tag">{flavor}</span>
              ))}
            </div>
          </div>

          <div className="add-to-cart-section">
            <div className="quantity-selector">
              <label htmlFor="quantity">Quantity:</label>
              <input
                type="number"
                id="quantity"
                min="1"
                max="10"
                value={quantity}
                onChange={handleQuantityChange}
              />
            </div>
            <button className="btn-primary add-to-cart-btn" onClick={handleAddToCart}>
              Add to Cart - ${(product.price * quantity).toFixed(2)}
            </button>
          </div>
        </div>
      </div>

      <div className="reviews-section">
        <h3>Customer Reviews</h3>
        <div className="reviews-list">
          {product.reviews.map(review => (
            <div key={review.id} className="review-item">
              <div className="review-header">
                <span className="review-user">{review.user}</span>
                <div className="review-rating">
                  {'★'.repeat(review.rating)}{'☆'.repeat(5 - review.rating)}
                </div>
              </div>
              <p className="review-comment">{review.comment}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default ProductDetail;
