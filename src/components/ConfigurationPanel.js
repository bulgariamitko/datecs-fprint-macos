import React, { useState } from 'react';
import { Save, Wifi, HardDrive } from 'lucide-react';

const ConfigurationPanel = ({ config, onSave }) => {
  const [formData, setFormData] = useState(config);
  const [saving, setSaving] = useState(false);

  const handleChange = (field, value) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      await onSave(formData);
    } finally {
      setSaving(false);
    }
  };

  const isValid = formData.ipAddress && formData.port && formData.deviceModel && formData.serialNumber;

  return (
    <div>
      <h2 className="mb-4">Printer Configuration</h2>

      <div className="grid grid-2 gap-4 mb-6">
        {/* Device Information */}
        <div>
          <h3 className="flex items-center gap-2 mb-4 text-lg font-medium">
            <HardDrive className="w-5 h-5" />
            Device Information
          </h3>

          <div className="form-group">
            <label>Country</label>
            <input
              type="text"
              value={formData.country || ''}
              onChange={(e) => handleChange('country', e.target.value)}
              placeholder="e.g., Bulgaria"
            />
          </div>

          <div className="form-group">
            <label>Device Model *</label>
            <select
              value={formData.deviceModel || ''}
              onChange={(e) => handleChange('deviceModel', e.target.value)}
            >
              <option value="">Select model...</option>
              <option value="DP-25MX">DP-25MX</option>
              <option value="DP-50X">DP-50X</option>
              <option value="FP-2000">FP-2000</option>
              <option value="Other">Other</option>
            </select>
          </div>

          <div className="form-group">
            <label>Serial Number *</label>
            <input
              type="text"
              value={formData.serialNumber || ''}
              onChange={(e) => handleChange('serialNumber', e.target.value)}
              placeholder="e.g., AB123456"
            />
          </div>

          <div className="form-group">
            <label>Fiscal Memory Number</label>
            <input
              type="text"
              value={formData.fiscalMemoryNumber || ''}
              onChange={(e) => handleChange('fiscalMemoryNumber', e.target.value)}
              placeholder="e.g., 12345678"
            />
          </div>
        </div>

        {/* Network Settings */}
        <div>
          <h3 className="flex items-center gap-2 mb-4 text-lg font-medium">
            <Wifi className="w-5 h-5" />
            Network Settings
          </h3>

          <div className="form-group">
            <label>IP Address *</label>
            <input
              type="text"
              value={formData.ipAddress || ''}
              onChange={(e) => handleChange('ipAddress', e.target.value)}
              placeholder="e.g., 192.168.1.100"
            />
          </div>

          <div className="form-group">
            <label>Port *</label>
            <input
              type="number"
              value={formData.port || ''}
              onChange={(e) => handleChange('port', parseInt(e.target.value) || '')}
              placeholder="4999"
              min="1"
              max="65535"
            />
          </div>

          <div className="form-group">
            <label>Connection Timeout (ms)</label>
            <input
              type="number"
              value={formData.timeout || 10000}
              onChange={(e) => handleChange('timeout', parseInt(e.target.value) || 10000)}
              placeholder="10000"
              min="1000"
              max="60000"
            />
          </div>

          <div className="form-group">
            <label>Operator Password</label>
            <input
              type="password"
              value={formData.operatorPassword || ''}
              onChange={(e) => handleChange('operatorPassword', e.target.value)}
              placeholder="Enter operator password"
            />
          </div>
        </div>
      </div>

      {/* Save Button */}
      <div className="flex justify-between items-center">
        <div className="text-muted">
          * Required fields
        </div>

        <button
          className="btn btn-primary"
          onClick={handleSave}
          disabled={!isValid || saving}
        >
          {saving ? (
            <>
              <div className="spinner" />
              Saving...
            </>
          ) : (
            <>
              <Save className="w-4 h-4" />
              Save Configuration
            </>
          )}
        </button>
      </div>

      {/* Configuration Preview */}
      {isValid && (
        <div className="mt-6 p-4 bg-gray-50 rounded-lg">
          <h4 className="font-medium mb-2">Configuration Summary:</h4>
          <div className="text-sm text-muted grid grid-2 gap-2">
            <div>Model: {formData.deviceModel}</div>
            <div>Connection: {formData.ipAddress}:{formData.port}</div>
            <div>Serial: {formData.serialNumber}</div>
            <div>Timeout: {formData.timeout}ms</div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ConfigurationPanel;