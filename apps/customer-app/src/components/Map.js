import React, { useEffect, useState } from 'react';
import { MapContainer, TileLayer, Marker, Popup, Polyline } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';

// Fix for default markers in react-leaflet
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: require('leaflet/dist/images/marker-icon-2x.png'),
  iconUrl: require('leaflet/dist/images/marker-icon.png'),
  shadowUrl: require('leaflet/dist/images/marker-shadow.png'),
});

const Map = ({ order, driverLocation, deliveryStatus }) => {
  const [route, setRoute] = useState([]);
  const [estimatedTime, setEstimatedTime] = useState(null);

  // Default center (you can replace with actual vendor location)
  const defaultCenter = [40.7128, -74.0060]; // New York City

  useEffect(() => {
    if (order && driverLocation) {
      // Calculate route between driver and delivery location
      calculateRoute(driverLocation, order.deliveryLatLng);
    }
  }, [order, driverLocation]);

  const calculateRoute = async (start, end) => {
    try {
      // Using OSRM (Open Source Routing Machine) API for routing
      // In production, you might want to use Google Maps or Mapbox Directions API
      const response = await fetch(
        `https://router.project-osrm.org/route/v1/driving/${start.lng},${start.lat};${end.lng},${end.lat}?overview=full&geometries=geojson`
      );

      if (response.ok) {
        const data = await response.json();
        if (data.routes && data.routes[0]) {
          const coordinates = data.routes[0].geometry.coordinates.map(coord => [coord[1], coord[0]]);
          setRoute(coordinates);

          // Calculate estimated time (duration in minutes)
          const duration = Math.round(data.routes[0].duration / 60);
          setEstimatedTime(duration);
        }
      }
    } catch (error) {
      console.error('Error calculating route:', error);
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'preparing': return 'orange';
      case 'ready': return 'blue';
      case 'picked_up': return 'purple';
      case 'in_transit': return 'green';
      case 'delivered': return 'gray';
      default: return 'gray';
    }
  };

  const getStatusMessage = (status) => {
    switch (status) {
      case 'preparing': return 'Preparing your order';
      case 'ready': return 'Ready for pickup';
      case 'picked_up': return 'Picked up by driver';
      case 'in_transit': return 'On the way to you';
      case 'delivered': return 'Delivered';
      default: return 'Order placed';
    }
  };

  if (!order) {
    return (
      <div className="bg-gray-100 rounded-lg p-8 text-center">
        <svg className="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" />
        </svg>
        <h3 className="text-lg font-medium text-gray-900 mb-2">No Active Delivery</h3>
        <p className="text-gray-600">Place an order to track your delivery in real-time</p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {/* Delivery Status */}
      <div className="bg-white rounded-lg shadow p-4">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-lg font-semibold text-gray-900">Delivery Status</h3>
            <p className="text-gray-600">{getStatusMessage(deliveryStatus)}</p>
          </div>
          <div className={`px-3 py-1 rounded-full text-sm font-medium ${
            deliveryStatus === 'delivered' ? 'bg-green-100 text-green-800' :
            deliveryStatus === 'in_transit' ? 'bg-blue-100 text-blue-800' :
            'bg-yellow-100 text-yellow-800'
          }`}>
            {deliveryStatus?.replace('_', ' ').toUpperCase()}
          </div>
        </div>

        {estimatedTime && deliveryStatus !== 'delivered' && (
          <div className="mt-3 flex items-center text-sm text-gray-600">
            <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            Estimated delivery in {estimatedTime} minutes
          </div>
        )}
      </div>

      {/* Map */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="h-96">
          <MapContainer
            center={driverLocation ? [driverLocation.lat, driverLocation.lng] : defaultCenter}
            zoom={13}
            style={{ height: '100%', width: '100%' }}
          >
            <TileLayer
              attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            />

            {/* Driver Location */}
            {driverLocation && (
              <Marker position={[driverLocation.lat, driverLocation.lng]}>
                <Popup>
                  <div className="text-center">
                    <div className="font-semibold">🚚 Driver Location</div>
                    <div className="text-sm text-gray-600">Your delivery driver</div>
                  </div>
                </Popup>
              </Marker>
            )}

            {/* Delivery Address */}
            {order.deliveryLatLng && (
              <Marker position={[order.deliveryLatLng.lat, order.deliveryLatLng.lng]}>
                <Popup>
                  <div className="text-center">
                    <div className="font-semibold">🏠 Delivery Address</div>
                    <div className="text-sm text-gray-600">{order.deliveryAddress}</div>
                  </div>
                </Popup>
              </Marker>
            )}

            {/* Route Line */}
            {route.length > 0 && (
              <Polyline
                positions={route}
                color={getStatusColor(deliveryStatus)}
                weight={4}
                opacity={0.7}
              />
            )}
          </MapContainer>
        </div>
      </div>

      {/* Delivery Details */}
      <div className="bg-white rounded-lg shadow p-4">
        <h4 className="font-semibold text-gray-900 mb-3">Delivery Details</h4>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
          <div>
            <span className="font-medium text-gray-600">Order ID:</span>
            <span className="ml-2 text-gray-900">#{order.id}</span>
          </div>
          <div>
            <span className="font-medium text-gray-600">Driver:</span>
            <span className="ml-2 text-gray-900">{order.driverName || 'Assigning driver...'}</span>
          </div>
          <div>
            <span className="font-medium text-gray-600">Delivery Address:</span>
            <span className="ml-2 text-gray-900">{order.deliveryAddress}</span>
          </div>
          <div>
            <span className="font-medium text-gray-600">Estimated Time:</span>
            <span className="ml-2 text-gray-900">
              {estimatedTime ? `${estimatedTime} minutes` : 'Calculating...'}
            </span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Map;
