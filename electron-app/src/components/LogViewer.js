import React, { useEffect, useRef } from 'react';
import { Trash2, Download } from 'lucide-react';

const LogViewer = ({ logs, onClear }) => {
  const logEndRef = useRef(null);

  // Auto-scroll to bottom when new logs are added
  useEffect(() => {
    logEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [logs]);

  const exportLogs = () => {
    const logText = logs.map(log =>
      `[${log.timestamp}] [${log.level.toUpperCase()}] ${log.message}`
    ).join('\\n');

    const blob = new Blob([logText], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `datecs-fprint-logs-${new Date().toISOString().split('T')[0]}.txt`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  };

  const getLogLevelClass = (level) => {
    switch (level) {
      case 'error':
        return 'log-level-error';
      case 'success':
        return 'log-level-success';
      case 'info':
      default:
        return 'log-level-info';
    }
  };

  return (
    <div>
      <div className="flex items-center justify-between mb-4">
        <h2>Activity Log</h2>
        <div className="flex gap-2">
          {logs.length > 0 && (
            <>
              <button
                className="btn btn-secondary"
                onClick={exportLogs}
                title="Export logs to file"
              >
                <Download className="w-4 h-4" />
                Export
              </button>
              <button
                className="btn btn-danger"
                onClick={onClear}
                title="Clear all logs"
              >
                <Trash2 className="w-4 h-4" />
                Clear
              </button>
            </>
          )}
        </div>
      </div>

      <div className="log-viewer">
        {logs.length === 0 ? (
          <div className="text-center text-muted py-4">
            No logs yet. Start by testing your connection.
          </div>
        ) : (
          logs.map((log) => (
            <div key={log.id} className="log-entry">
              <span className="log-timestamp">[{log.timestamp}]</span>
              <span className={getLogLevelClass(log.level)}>
                {log.message}
              </span>
            </div>
          ))
        )}
        <div ref={logEndRef} />
      </div>

      {logs.length > 0 && (
        <div className="mt-2 text-xs text-muted">
          {logs.length} log {logs.length === 1 ? 'entry' : 'entries'}
        </div>
      )}
    </div>
  );
};

export default LogViewer;