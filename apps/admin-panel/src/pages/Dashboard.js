import React, { useState, useEffect } from 'react';
import './Dashboard.css';

function Dashboard() {
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalVendors: 0,
    totalOrders: 0,
    totalRevenue: 0
  });

  const [recentActivity, setRecentActivity] = useState([]);

  useEffect(() => {
    // TODO: Fetch real data from API
    // For now, using placeholder data
    setStats({
      totalUsers: 1250,
      totalVendors: 45,
      totalOrders: 320,
      totalRevenue: 45600
    });

    setRecentActivity([
      { id: 1, action: 'New vendor registered', time: '2 hours ago' },
      { id: 2, action: 'Order #1234 completed', time: '4 hours ago' },
      { id: 3, action: 'User John Doe verified', time: '6 hours ago' },
      { id: 4, action: 'New product added by Vendor ABC', time: '8 hours ago' },
      { id: 5, action: 'Payment processed for Order #1233', time: '10 hours ago' }
    ]);
  }, []);

  return (
    <div className="dashboard">
      <h1>Admin Dashboard</h1>

      <div className="stats-grid">
        <div className="stat-card">
          <h3>Total Users</h3>
          <p className="stat-number">{stats.totalUsers.toLocaleString()}</p>
        </div>

        <div className="stat-card">
          <h3>Total Vendors</h3>
          <p className="stat-number">{stats.totalVendors.toLocaleString()}</p>
        </div>

        <div className="stat-card">
          <h3>Total Orders</h3>
          <p className="stat-number">{stats.totalOrders.toLocaleString()}</p>
        </div>

        <div className="stat-card">
          <h3>Total Revenue</h3>
          <p className="stat-number">${stats.totalRevenue.toLocaleString()}</p>
        </div>
      </div>

      <div className="recent-activity">
        <h2>Recent Activity</h2>
        <div className="activity-list">
          {recentActivity.map(activity => (
            <div key={activity.id} className="activity-item">
              <span>{activity.action}</span>
              <span className="activity-time">{activity.time}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

export default Dashboard;
