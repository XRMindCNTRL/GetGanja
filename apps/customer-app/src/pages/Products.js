import React, { useState, useEffect } from 'react';

const Products = ({ addToCart }) => {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filters, setFilters] = useState({
    category: '',
    priceRange: '',
    search: ''
  });

  // Mock data - replace with API call
  useEffect(() => {
    const mockProducts = [
      {
        id: 1,
        name: 'Premium Cannabis Flower',
        category: 'Flower',
        price: 45.99,
        image: '/api/placeholder/300/300',
        description: 'High-quality cannabis flower with THC content of 22%'
      },
      {
        id: 2,
        name: 'CBD Oil Tincture',
        category: 'Oil',
        price: 29.99,
        image: '/api/placeholder/300/300',
        description: 'Full-spectrum CBD oil for relaxation and wellness'
      },
      {
        id: 3,
        name: 'Edible Gummies',
        category: 'Edibles',
        price: 19.99,
        image: '/api/placeholder/300/300',
        description: 'Delicious THC-infused gummies in various flavors'
      }
    ];

    setTimeout(() => {
      setProducts(mockProducts);
      setLoading(false);
    }, 1000);
  }, []);

  const handleFilterChange = (e) => {
    const { name, value } = e.target;
    setFilters(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const filteredProducts = products.filter(product => {
    const matchesCategory = !filters.category || product.category === filters.category;
    const matchesSearch = !filters.search ||
      product.name.toLowerCase().includes(filters.search.toLowerCase()) ||
      product.description.toLowerCase().includes(filters.search.toLowerCase());

    return matchesCategory && matchesSearch;
  });

  if (loading) {
    return (
      <div className="products-page">
        <div className="loading">Loading products...</div>
      </div>
    );
  }

  return (
    <div className="products-page">
      <div className="products-header">
        <h1>Our Products</h1>
        <p>Discover our premium cannabis selection</p>
      </div>

      <div className="filters-section">
        <div className="search-bar">
          <input
            type="text"
            name="search"
            placeholder="Search products..."
            value={filters.search}
            onChange={handleFilterChange}
          />
        </div>

        <div className="filter-controls">
          <select name="category" value={filters.category} onChange={handleFilterChange}>
            <option value="">All Categories</option>
            <option value="Flower">Flower</option>
            <option value="Oil">Oil</option>
            <option value="Edibles">Edibles</option>
          </select>
        </div>
      </div>

      <div className="products-grid">
        {filteredProducts.map(product => (
          <div key={product.id} className="product-card">
            <div className="product-image">
              <img src={product.image} alt={product.name} />
            </div>
            <div className="product-info">
              <h3>{product.name}</h3>
              <p className="category">{product.category}</p>
              <p className="description">{product.description}</p>
              <div className="product-footer">
                <span className="price">${product.price}</span>
                <button className="btn-primary" onClick={() => addToCart(product)}>Add to Cart</button>
              </div>
            </div>
          </div>
        ))}
      </div>

      {filteredProducts.length === 0 && (
        <div className="no-products">
          <p>No products found matching your criteria.</p>
        </div>
      )}
    </div>
  );
};

export default Products;
