import React, { useState, useEffect } from 'react';

const Vendors = () => {
  const [vendors, setVendors] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState('ALL');

  useEffect(() => {
    fetchVendors();
  }, []);

  const fetchVendors = async () => {
    try {
      // Mock data for now - replace with actual API call
      const mockVendors = [
        {
          id: '1',
          businessName: 'Green Leaf Dispensary',
          businessType: 'Retail',
          licenseNumber: 'LIC-2024-001',
          licenseExpiry: '2025-12-31',
          address: '123 Main St, City, Province',
          phone: '+1-555-0123',
          email: 'contact@greenleaf.com',
          isApproved: true,
          totalProducts: 45,
          totalOrders: 128,
          rating: 4.8,
          createdAt: '2024-01-15'
        },
        {
          id: '2',
          businessName: 'Herbal Remedies Co',
          businessType: 'Online',
          licenseNumber: 'LIC-2024-002',
          licenseExpiry: '2025-11-30',
          address: '456 Oak Ave, City, Province',
          phone: '+1-555-0456',
          email: 'info@herbalremedies.com',
          isApproved: false,
          totalProducts: 23,
          totalOrders: 0,
          rating: 0,
          createdAt: '2024-01-20'
        }
      ];
      setVendors(mockVendors);
      setLoading(false);
    } catch (error) {
      console.error('Error fetching vendors:', error);
      setLoading(false);
    }
  };

  const filteredVendors = vendors.filter(vendor => {
    const matchesSearch = vendor.businessName.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         vendor.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         vendor.licenseNumber.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = filterStatus === 'ALL' ||
                         (filterStatus === 'APPROVED' && vendor.isApproved) ||
                         (filterStatus === 'PENDING' && !vendor.isApproved);
    return matchesSearch && matchesStatus;
  });

  const toggleApproval = async (vendorId, currentStatus) => {
    try {
      // Mock API call - replace with actual API
      setVendors(vendors.map(vendor =>
        vendor.id === vendorId ? { ...vendor, isApproved: !currentStatus } : vendor
      ));
    } catch (error) {
      console.error('Error updating vendor approval:', error);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Vendor Management</h1>
        <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
          Add New Vendor
        </button>
      </div>

      {/* Filters */}
      <div className="flex gap-4 mb-6">
        <input
          type="text"
          placeholder="Search vendors..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        />
        <select
          value={filterStatus}
          onChange={(e) => setFilterStatus(e.target.value)}
          className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        >
          <option value="ALL">All Status</option>
          <option value="APPROVED">Approved</option>
          <option value="PENDING">Pending Approval</option>
        </select>
      </div>

      {/* Vendors Table */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Business
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                License
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Status
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Products
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Orders
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Rating
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {filteredVendors.map((vendor) => (
              <tr key={vendor.id} className="hover:bg-gray-50">
                <td className="px-6 py-4 whitespace-nowrap">
                  <div>
                    <div className="text-sm font-medium text-gray-900">
                      {vendor.businessName}
                    </div>
                    <div className="text-sm text-gray-500">{vendor.businessType}</div>
                    <div className="text-sm text-gray-500">{vendor.email}</div>
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="text-sm text-gray-900">{vendor.licenseNumber}</div>
                  <div className="text-sm text-gray-500">
                    Expires: {new Date(vendor.licenseExpiry).toLocaleDateString()}
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                    vendor.isApproved ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'
                  }`}>
                    {vendor.isApproved ? 'Approved' : 'Pending'}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {vendor.totalProducts}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {vendor.totalOrders}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {vendor.rating > 0 ? `${vendor.rating} ⭐` : 'N/A'}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  {!vendor.isApproved && (
                    <button
                      onClick={() => toggleApproval(vendor.id, vendor.isApproved)}
                      className="mr-2 px-3 py-1 rounded text-xs bg-green-100 text-green-800 hover:bg-green-200"
                    >
                      Approve
                    </button>
                  )}
                  <button className="mr-2 px-3 py-1 rounded text-xs bg-blue-100 text-blue-800 hover:bg-blue-200">
                    View
                  </button>
                  <button className="px-3 py-1 rounded text-xs bg-red-100 text-red-800 hover:bg-red-200">
                    Suspend
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {filteredVendors.length === 0 && (
        <div className="text-center py-12">
          <p className="text-gray-500">No vendors found matching your criteria.</p>
        </div>
      )}
    </div>
  );
};

export default Vendors;
