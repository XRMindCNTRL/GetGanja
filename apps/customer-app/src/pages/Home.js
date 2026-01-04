import React from 'react';

const Home = () => {
  return (
    <div className="home-page">
      <div className="hero-section">
        <h1>Welcome to Cannabis Delivery Platform</h1>
        <p>Your trusted online cannabis delivery service</p>
        <div className="hero-buttons">
          <button className="btn-primary">Browse Products</button>
          <button className="btn-secondary">Sign Up</button>
        </div>
      </div>

      <div className="features-section">
        <h2>Why Choose Us?</h2>
        <div className="features-grid">
          <div className="feature-card">
            <h3>🚚 Fast Delivery</h3>
            <p>Quick and reliable delivery to your doorstep</p>
          </div>
          <div className="feature-card">
            <h3>🌿 Quality Products</h3>
            <p>Premium cannabis products from trusted vendors</p>
          </div>
          <div className="feature-card">
            <h3>🔒 Secure Payment</h3>
            <p>Safe and secure payment processing</p>
          </div>
          <div className="feature-card">
            <h3>📱 Easy Ordering</h3>
            <p>Simple and intuitive ordering process</p>
          </div>
        </div>
      </div>

      <div className="cta-section">
        <h2>Ready to Get Started?</h2>
        <p>Join thousands of satisfied customers</p>
        <button className="btn-primary">Shop Now</button>
      </div>
    </div>
  );
};

export default Home;
