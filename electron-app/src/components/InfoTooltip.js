import React from 'react';
import { Info } from 'lucide-react';

const InfoTooltip = ({ content }) => {
  return (
    <div className="info-tooltip">
      <Info className="w-4 h-4" />
      <div className="tooltip-content">
        {content}
      </div>
    </div>
  );
};

export default InfoTooltip;