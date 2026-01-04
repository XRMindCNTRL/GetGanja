import React, { useState } from 'react';

const Orders = () => {
  const [orders, setOrders] = useState([
    {
      id: 1,
      orderNumber: '#ORD-001',
      customerName: 'Alice Johnson',
      customerPhone: '+27 82 123 4567',
      address: '123 Main St, Johannesburg, 2001',
      items: [
        { name: 'Blue Dream (1g)', quantity: 1, price: 150 },
        { name: 'OG Kush (0.5g)', quantity: 1, price: 120 }
      ],
      total: 270,
      status: 'Pending',
      orderTime: '2024-01-15 14:30',
      estimatedDelivery: '15-30 mins'
    },
    {
      id: 2,
      orderNumber: '#ORD-002',
      customerName: 'Bob Smith',
      customerPhone: '+27 83 987 6543',
      address: '456 Oak Ave, Cape Town, 8001',
      items: [
        { name: 'Sour Diesel (2g)', quantity: 1, price: 300 },
        { name: 'Girl Scout Cookies (1g)', quantity: 1, price: 180 }
      ],
      total: 480,
      status: 'Accepted',
      orderTime: '2024-01-15 14:15',
      estimatedDelivery: '20-35 mins'
    },
    {
      id: 3,
      orderNumber: '#ORD-003',
      customerName: 'Carol Davis',
      customerPhone: '+27 84 555 7890',
      address: '789 Pine Rd, Durban, 4001',
      items: [
        { name: 'Northern Lights (1.5g)', quantity: 1, price: 225 }
      ],
      total: 225,
      status: 'Delivered',
      orderTime: '2024-01-15 13:45',
      estimatedDelivery: 'Delivered at 14:05'
    }
  ]);

  const acceptOrder = (id) => {
    setOrders(orders.map(order =>
      order.id === id ? { ...order, status: 'Accepted' } : order
    ));
  };

  const rejectOrder = (id) => {
    setOrders(orders.filter(order => order.id !== id));
  };

  const markDelivered = (id) => {
    setOrders(orders.map(order =>
      order.id === id ? { ...order, status: 'Delivered' } : order
    ));
  };

  const callCustomer = (phone) => {
    window.location.href = `tel:${phone}`;
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'Pending': return 'bg-yellow-100 text-yellow-800';
      case 'Accepted': return 'bg-blue-100 text-blue-800';
      case 'Delivered': return 'bg-green-100 text-green-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <div className="p-6">
      <h2 className="text-3xl font-bold mb-6">Orders</h2>

      <div className="space-y-6">
        {orders.map(order => (
          <div key={order.id} className="bg-white rounded-lg shadow-md p-6">
            <div className="flex justify-between items-start mb-4">
              <div>
                <h3 className="text-xl font-semibold">{order.orderNumber}</h3>
                <p className="text-gray-600">{order.customerName}</p>
                <p className="text-sm text-gray-500">{order.orderTime}</p>
              </div>
              <div className="text-right">
                <span className={`px-3 py-1 rounded-full text-sm ${getStatusColor(order.status)}`}>
                  {order.status}
                </span>
                <p className="text-lg font-bold text-green-600 mt-2">R{order.total}</p>
              </div>
            </div>

            <div className="mb-4">
              <h4 className="font-semibold mb-2">Delivery Address:</h4>
              <p className="text-gray-700">{order.address}</p>
            </div>

            <div className="mb-4">
              <h4 className="font-semibold mb-2">Items:</h4>
              <div className="space-y-1">
                {order.items.map((item, index) => (
                  <div key={index} className="flex justify-between text-sm">
                    <span>{item.name} x{item.quantity}</span>
                    <span>R{item.price}</span>
                  </div>
                ))}
              </div>
            </div>

            <div className="mb-4">
              <p className="text-sm text-gray-600">
                <span className="font-semibold">Estimated Delivery:</span> {order.estimatedDelivery}
              </p>
            </div>

            <div className="flex justify-between items-center">
              <button
                onClick={() => callCustomer(order.customerPhone)}
                className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 flex items-center space-x-2"
              >
                <span>📞</span>
                <span>Call Customer</span>
              </button>

              <div className="space-x-2">
                {order.status === 'Pending' && (
                  <>
                    <button
                      onClick={() => acceptOrder(order.id)}
                      className="bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600"
                    >
                      Accept
                    </button>
                    <button
                      onClick={() => rejectOrder(order.id)}
                      className="bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600"
                    >
                      Reject
                    </button>
                  </>
                )}
                {order.status === 'Accepted' && (
                  <button
                    onClick={() => markDelivered(order.id)}
                    className="bg-purple-500 text-white px-4 py-2 rounded hover:bg-purple-600"
                  >
                    Mark Delivered
                  </button>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Orders;
