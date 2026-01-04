import React from 'react';

const Header = () => {
  return (
    <header className="bg-green-600 text-white shadow-lg">
      <div className="container mx-auto px-4 py-4 flex justify-between items-center">
        <div className="flex items-center space-x-4">
          <h1 className="text-2xl font-bold">Driver App</h1>
          <span className="bg-green-500 px-3 py-1 rounded-full text-sm">Online</span>
        </div>
        <div className="flex items-center space-x-4">
          <div className="text-right">
            <p className="font-semibold">John Driver</p>
            <p className="text-sm text-green-100">Driver ID: #12345</p>
          </div>
          <div className="w-10 h-10 bg-green-500 rounded-full flex items-center justify-center">
            <span className="text-white font-bold">JD</span>
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;
