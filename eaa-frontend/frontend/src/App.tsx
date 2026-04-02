import React from 'react';

type WorkMode = 'rule_design' | 'novel_creation' | 'balance_adjustment' | 'harness_management';

export default function App() {
  const [workMode, setWorkMode] = React.useState<WorkMode>('rule_design');

  return (
    <div className="flex flex-col h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b border-gray-200 px-6 py-4">
        <div className="flex items-center justify-between">
          <h1 className="text-xl font-bold text-gray-900">
            Echo Ad Astra 前端工具
          </h1>
          <select
            value={workMode}
            onChange={(e) => setWorkMode(e.target.value as WorkMode)}
            className="border border-gray-300 rounded-lg px-4 py-2"
          >
            <option value="rule_design">规则设计模式</option>
            <option value="novel_creation">小说创作模式</option>
            <option value="balance_adjustment">平衡调整模式</option>
            <option value="harness_management">Harness 管理模式</option>
          </select>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-1 flex overflow-hidden">
        {workMode === 'rule_design' && (
          <div className="flex-1 flex items-center justify-center">
            <p className="text-gray-600">规则编辑器 - 开发中</p>
          </div>
        )}
        {workMode === 'novel_creation' && (
          <div className="flex-1 flex items-center justify-center">
            <p className="text-gray-600">小说创作助手 - 开发中</p>
          </div>
        )}
        {workMode === 'balance_adjustment' && (
          <div className="flex-1 flex items-center justify-center">
            <p className="text-gray-600">数值平衡工具 - 开发中</p>
          </div>
        )}
        {workMode === 'harness_management' && (
          <div className="flex-1 flex items-center justify-center">
            <p className="text-gray-600">Harness 管理面板 - 开发中</p>
          </div>
        )}
      </main>
    </div>
  );
}
