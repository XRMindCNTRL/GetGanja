import React, { useState } from 'react';

const Dashboard = () => {
  const [activeDeliveries, setActiveDeliveries] = useState([
    {
      id: 1,
      orderNumber: '#ORD-001',
      customerName: 'Alice Johnson',
      address: '123 Main St, Johannesburg, 2001',
      status: 'Picked Up',
      estimatedArrival: '15 mins',
      total: 270
    },
    {
      id: 2,
      orderNumber: '#ORD-002',
      customerName: 'Bob Smith',
      address: '456 Oak Ave, Cape Town, 8001',
      status: 'En Route',
      estimatedArrival: '8 mins',
      total: 480
    }
  ]);

  const [completedDeliveries, setCompletedDeliveries] = useState([
    {
      id: 3,
      orderNumber: '#ORD-003',
      customerName: 'Carol Davis',
      address: '789 Pine Rd, Durban, 4001',
      completedAt: '14:05',
      total: 225
    }
  ]);

  const updateStatus = (id, newStatus) => {
    setActiveDeliveries(deliveries =>
      deliveries.map(delivery =>
        delivery.id === id ? { ...delivery, status: newStatus } : delivery
      )
    );
  };

  const completeDelivery = (id) => {
    const delivery = activeDeliveries.find(d => d.id === id);
    if (delivery) {
      setActiveDeliveries(deliveries => deliveries.filter(d => d.id !== id));
      setCompletedDeliveries(completed => [...completed, {
        ...delivery,
        completedAt: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        status: 'Delivered'
      }]);
    }
  };

  const stats = {
    activeDeliveries: activeDeliveries.length,
    completedToday: completedDeliveries.length,
    earnings: activeDeliveries.reduce((sum, d) => sum + d.total, 0) + completedDeliveries.reduce((sum, d) => sum + d.total, 0),
    rating: 4.8
  };

  return (
    <div className="p-6">
      <h2 className="text-3xl font-bold mb-6">Dashboard</h2>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div className="bg-white rounded-lg shadow-md p-6">
          <div className="flex items-center">
            <div className="bg-blue-500 text-white p-3 rounded-full">
              🚚
            </div>
            <div className="ml-4">
              <p className="text-gray-600">Active Deliveries</p>
              <p className="text-2xl font-bold">{stats.activeDeliveries}</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-md p-6">
          <div className="flex items-center">
            <div className="bg-green-500 text-white p-3 rounded-full">
              ✅
            </div>
            <div className="ml-4">
              <p className="text-gray-600">Completed Today</p>
              <p className="text-2xl font-bold">{stats.completedToday}</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-md p-6">
          <div className="flex items-center">
            <div className="bg-purple-500 text-white p-3 rounded-full">
              💰
            </div>
            <div className="ml-4">
              <p className="text-gray-600">Earnings Today</p>
              <p className="text-2xl font-bold">R{stats.earnings}</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-md p-6">
          <div className="flex items-center">
            <div className="bg-yellow-500 text-white p-3 rounded-full">
              ⭐
            </div>
            <div className="ml-4">
              <p className="text-gray-600">Rating</p>
              <p className="text-2xl font-bold">{stats.rating}/5</p>
            </div>
          </div>
        </div>
      </div>

      {/* Active Deliveries */}
      <div className="mb-8">
        <h3 className="text-2xl font-bold mb-4">Active Deliveries</h3>
        <div className="space-y-4">
          {activeDeliveries.map(delivery => (
            <div key={delivery.id} className="bg-white rounded-lg shadow-md p-6">
              <div className="flex justify-between items-start mb-4">
                <div>
                  <h4 className="text-xl font-semibold">{delivery.orderNumber}</h4>
                  <p className="text-gray-600">{delivery.customerName}</p>
                  <p className="text-sm text-gray-500">{delivery.address}</p>
                </div>
                <div className="text-right">
                  <span className="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm">
                    {delivery.status}
                  </span>
                  <p className="text-lg font-bold text-green-600 mt-2">R{delivery.total}</p>
                </div>
              </div>

              <div className="flex justify-between items-center">
                <p className="text-sm text-gray-600">
                  <span className="font-semibold">ETA:</span> {delivery.estimatedArrival}
                </p>
                <div className="space-x-2">
                  {delivery.status === 'Picked Up' && (
                    <button
                      onClick={() => updateStatus(delivery.id, 'En Route')}
                      className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
                    >
                      Start Delivery
                    </button>
                  )}
                  {delivery.status === 'En Route' && (
                    <button
                      onClick={() => completeDelivery(delivery.id)}
                      className="bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600"
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

      {/* Completed Deliveries */}
      <div>
        <h3 className="text-2xl font-bold mb-4">Completed Today</h3>
        <div className="bg-white rounded-lg shadow-md overflow-hidden">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Order
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Customer
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Address
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Completed
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Amount
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {completedDeliveries.map(delivery => (
                <tr key={delivery.id}>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {delivery.orderNumber}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {delivery.customerName}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {delivery.address}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {delivery.completedAt}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-green-600">
                    R{delivery.total}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
