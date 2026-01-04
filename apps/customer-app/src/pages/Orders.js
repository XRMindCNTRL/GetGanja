import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';

const Orders = ({ user }) => {
  const navigate = useNavigate();
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user) {
      navigate('/login');
      return;
    }

    // Mock data - in real app this would come from API
    const mockOrders = [
      {
        id: 'ORD-001',
        date: '2024-12-10',
        status: 'Delivered',
        total: 67.98,
        items: [
          { name: 'Blue Dream Flower', quantity: 1, price: 45.99 },
          { name: 'OG Kush Pre-Roll', quantity: 2, price: 12.99 }
        ]
      },
      {
        id: 'ORD-002',
        date: '2024-12-08',
        status: 'In Transit',
        total: 29.99,
        items: [
          { name: 'Calm CBD Gummies', quantity: 1, price: 29.99 }
        ]
      },
      {
        id: 'ORD-003',
        date: '2024-12-05',
        status: 'Delivered',
        total: 89.97,
        items: [
          { name: 'Blue Dream Flower', quantity: 2, price: 45.99 },
          { name: 'Sour Diesel Vape Cartridge', quantity: 1, price: 24.99 }
        ]
      }
    ];

    setTimeout(() => {
      setOrders(mockOrders);
      setLoading(false);
    }, 1000);
  }, [user, navigate]);

  const getStatusColor = (status) => {
    switch (status) {
      case 'Delivered':
        return 'bg-green-100 text-green-800';
      case 'In Transit':
        return 'bg-blue-100 text-blue-800';
      case 'Processing':
        return 'bg-yellow-100 text-yellow-800';
      case 'Cancelled':
        return 'bg-red-100 text-red-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  if (!user) {
    return null; // Will redirect in useEffect
  }

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600"></div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-gray-900 mb-2">My Orders</h1>
        <p className="text-gray-600">Track and manage your cannabis delivery orders</p>
      </div>

      {orders.length === 0 ? (
        <div className="text-center py-16">
          <svg className="mx-auto h-24 w-24 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
          </svg>
          <h3 className="mt-4 text-lg font-medium text-gray-900">No orders yet</h3>
          <p className="mt-2 text-gray-500">When you place your first order, it will appear here.</p>
          <button
            onClick={() => navigate('/products')}
            className="mt-6 bg-green-600 text-white px-6 py-3 rounded-lg font-semibold hover:bg-green-700 transition-colors"
          >
            Start Shopping
          </button>
        </div>
      ) : (
        <div className="space-y-6">
          {orders.map((order) => (
            <div key={order.id} className="bg-white rounded-lg shadow-md p-6">
              <div className="flex justify-between items-start mb-4">
                <div>
                  <h3 className="text-lg font-semibold text-gray-900">Order #{order.id}</h3>
                  <p className="text-gray-600">Placed on {new Date(order.date).toLocaleDateString()}</p>
                </div>
                <div className="text-right">
                  <span className={`inline-block px-3 py-1 rounded-full text-sm font-medium ${getStatusColor(order.status)}`}>
                    {order.status}
                  </span>
                  <p className="text-lg font-bold text-gray-900 mt-1">${order.total.toFixed(2)}</p>
                </div>
              </div>

              <div className="border-t border-gray-200 pt-4">
                <h4 className="font-medium text-gray-900 mb-3">Items Ordered:</h4>
                <div className="space-y-2">
                  {order.items.map((item, index) => (
                    <div key={index} className="flex justify-between items-center py-2">
                      <div className="flex-1">
                        <span className="font-medium text-gray-900">{item.name}</span>
                        <span className="text-gray-600 ml-2">x{item.quantity}</span>
                      </div>
                      <span className="text-gray-900">${(item.price * item.quantity).toFixed(2)}</span>
                    </div>
                  ))}
                </div>
              </div>

              <div className="border-t border-gray-200 pt-4 mt-4 flex justify-between items-center">
                <div className="text-sm text-gray-600">
                  {order.status === 'In Transit' && 'Estimated delivery: Tomorrow'}
                  {order.status === 'Delivered' && 'Delivered successfully'}
                  {order.status === 'Processing' && 'Order is being prepared'}
                </div>
                <button className="text-green-600 hover:text-green-700 font-medium">
                  View Details
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Order History Info */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <div className="flex">
          <div className="flex-shrink-0">
            <svg className="h-5 w-5 text-blue-400" viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clipRule="evenodd" />
            </svg>
          </div>
          <div className="ml-3">
            <h3 className="text-sm font-medium text-blue-800">Order History</h3>
            <p className="mt-2 text-sm text-blue-700">
              Your order history is kept for 2 years. If you need older records or have questions about an order,
              please contact our customer support.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Orders;
