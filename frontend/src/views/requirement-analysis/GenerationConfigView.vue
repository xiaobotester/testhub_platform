<template>
  <div class="generation-config">
    <div class="page-header">
      <h1>⚙️ 生成行为配置</h1>
      <p>配置测试用例生成的默认行为和自动化流程</p>
    </div>

    <div class="main-content">
      <!-- 配置列表 -->
      <div class="configs-section">
        <div class="section-header">
          <h2>配置列表</h2>
          <button class="add-config-btn" @click="openAddModal">
            ➕ 添加配置
          </button>
        </div>

        <div class="configs-grid">
          <div v-for="config in configs" :key="config.id" class="config-card">
            <div class="config-header">
              <div class="config-title">
                <h3>{{ config.name }}</h3>
                <div class="config-badges">
                  <span class="status-badge" :class="{ active: config.is_active }">
                    {{ config.is_active ? '✅ 启用中' : '❌ 未启用' }}
                  </span>
                  <span class="mode-badge">
                    {{ config.default_output_mode === 'stream' ? '⚡ 流式输出' : '📄 完整输出' }}
                  </span>
                </div>
              </div>
              <div class="config-actions">
                <button v-if="!config.is_active" class="enable-btn" @click="enableConfig(config.id)">
                  ✅ 启用
                </button>
                <button class="edit-btn" @click="editConfig(config)">✏️ 编辑</button>
                <button class="delete-btn" @click="deleteConfig(config.id)">🗑️ 删除</button>
              </div>
            </div>

            <div class="config-details">
              <div class="detail-section">
                <h4>📤 输出模式</h4>
                <div class="detail-item">
                  <label>默认模式:</label>
                  <span>{{ config.default_output_mode_display }}</span>
                </div>
              </div>

              <div class="detail-section">
                <h4>🤖 自动化流程</h4>
                <div class="detail-item">
                  <label>AI评审和改进:</label>
                  <span :class="{ enabled: config.enable_auto_review, disabled: !config.enable_auto_review }">
                    {{ config.enable_auto_review ? '✅ 启用' : '❌ 禁用' }}
                  </span>
                </div>
              </div>

              <div class="detail-section">
                <h4>⏱️ 超时设置</h4>
                <div class="detail-item">
                  <label>评审和改进超时:</label>
                  <span>{{ config.review_timeout }} 秒</span>
                </div>
              </div>

              <div class="config-meta">
                <div class="meta-item">
                  <label>创建时间:</label>
                  <span>{{ formatDateTime(config.created_at) }}</span>
                </div>
                <div class="meta-item">
                  <label>更新时间:</label>
                  <span>{{ formatDateTime(config.updated_at) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div v-if="configs.length === 0" class="empty-state">
          <div class="empty-icon">⚙️</div>
          <h3>暂无生成配置</h3>
          <p>请添加生成行为配置以控制测试用例生成的默认行为</p>
          <button class="add-first-config-btn" @click="openAddModal">
            ➕ 添加第一个配置
          </button>
        </div>
      </div>
    </div>

    <!-- 添加/编辑配置弹窗 -->
    <div v-if="showAddModal || showEditModal" class="config-modal" @click="closeModals">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>{{ isEditing ? '编辑' : '添加' }}生成行为配置</h3>
          <button class="close-btn" @click="closeModals">×</button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="saveConfig">
            <div class="form-section">
              <h4>📋 基本信息</h4>
              <div class="form-group">
                <label>配置名称 <span class="required">*</span></label>
                <input
                  v-model="configForm.name"
                  type="text"
                  class="form-input"
                  placeholder="例如：默认生成配置"
                  required>
              </div>

              <div class="form-group">
                <label class="checkbox-label">
                  <input v-model="configForm.is_active" type="checkbox">
                  <span class="checkmark"></span>
                  启用此配置
                </label>
                <div class="checkbox-hint">
                  注意：只能有一个启用的配置，启用此配置将自动禁用其他配置
                </div>
              </div>
            </div>

            <div class="form-section">
              <h4>📤 输出模式设置</h4>
              <div class="form-group">
                <label>默认输出模式 <span class="required">*</span></label>
                <select v-model="configForm.default_output_mode" class="form-select" required>
                  <option value="stream">⚡ 实时流式输出</option>
                  <option value="complete">📄 完整输出</option>
                </select>
                <div class="field-hint">
                  实时流式输出：内容逐字显示，体验流畅；完整输出：完成后一次性展示
                </div>
              </div>
            </div>

            <div class="form-section">
              <h4>🤖 自动化流程配置</h4>
              <div class="form-group">
                <label class="checkbox-label">
                  <input v-model="configForm.enable_auto_review" type="checkbox">
                  <span class="checkmark"></span>
                  启用AI评审和改进
                </label>
                <div class="checkbox-hint">
                  生成完成后自动进行AI评审，并根据评审意见改进测试用例
                </div>
              </div>
            </div>

            <div class="form-section">
              <h4>⏱️ 超时设置</h4>
              <div class="form-group">
                <label>评审和改进超时时间（秒）</label>
                <input
                  v-model.number="configForm.review_timeout"
                  type="number"
                  class="form-input"
                  min="10"
                  max="3600">
                <div class="field-hint">AI评审和改进的总超时时间（建议：小文档120秒，大文档600-1800秒，超大文档可设置到3600秒）</div>
              </div>
            </div>

            <div class="modal-actions">
              <button type="button" class="cancel-btn" @click="closeModals">取消</button>
              <button
                type="submit"
                class="confirm-btn"
                :disabled="isSaving">
                <span v-if="isSaving">🔄 保存中...</span>
                <span v-else>💾 保存配置</span>
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { getGenerationConfigs, createGenerationConfig, updateGenerationConfig, deleteGenerationConfig } from '@/api/requirement-analysis'
import api from '@/utils/api'
import { ElMessage } from 'element-plus'

export default {
  name: 'GenerationConfigView',
  data() {
    return {
      configs: [],
      showAddModal: false,
      showEditModal: false,
      isEditing: false,
      isSaving: false,
      editingConfigId: null,
      configForm: {
        name: '默认生成配置',
        default_output_mode: 'stream',
        enable_auto_review: true,
        review_timeout: 1500,
        is_active: true
      }
    }
  },

  mounted() {
    this.loadConfigs()
  },

  methods: {
    openAddModal() {
      this.resetForm()
      this.isEditing = false
      this.showAddModal = true
    },

    async loadConfigs() {
      try {
        console.log('Loading generation configs...')
        const response = await getGenerationConfigs()
        console.log('Generation configs API response:', response.data)

        // 处理分页API响应格式
        if (response.data && response.data.results && Array.isArray(response.data.results)) {
          this.configs = response.data.results
        } else if (response.data && Array.isArray(response.data)) {
          this.configs = response.data
        } else {
          console.warn('Unexpected API response format:', response.data)
          this.configs = []
        }

        console.log('Final configs count:', this.configs.length)
      } catch (error) {
        console.error('加载配置失败:', error)
        this.configs = []

        if (error.response?.status === 401) {
          ElMessage.error('请先登录')
        } else {
          ElMessage.error('加载配置失败: ' + (error.response?.data?.error || error.message))
        }
      }
    },

    resetForm() {
      this.configForm = {
        name: '默认生成配置',
        default_output_mode: 'stream',
        enable_auto_review: true,
        review_timeout: 1500,
        is_active: true
      }
    },

    editConfig(config) {
      this.isEditing = true
      this.editingConfigId = config.id
      this.configForm = {
        name: config.name,
        default_output_mode: config.default_output_mode,
        enable_auto_review: config.enable_auto_review,
        review_timeout: config.review_timeout,
        is_active: config.is_active
      }
      this.showEditModal = true
    },

    async saveConfig() {
      this.isSaving = true

      try {
        if (this.isEditing) {
          await updateGenerationConfig(this.editingConfigId, this.configForm)
          ElMessage.success('配置更新成功')
        } else {
          await createGenerationConfig(this.configForm)
          ElMessage.success('配置添加成功')
        }

        this.closeModals()
        this.loadConfigs()
      } catch (error) {
        console.error('保存配置失败:', error)
        ElMessage.error('保存失败: ' + (error.response?.data?.error || error.message))
      } finally {
        this.isSaving = false
      }
    },

    async enableConfig(configId) {
      try {
        await api.post(`/requirement-analysis/generation-config/${configId}/enable/`)
        ElMessage.success('配置已启用')
        this.loadConfigs()
      } catch (error) {
        console.error('启用配置失败:', error)
        ElMessage.error('启用失败: ' + (error.response?.data?.error || error.message))
      }
    },

    async deleteConfig(configId) {
      if (!confirm('确定要删除此配置吗？')) {
        return
      }

      try {
        await deleteGenerationConfig(configId)
        ElMessage.success('配置删除成功')
        this.loadConfigs()
      } catch (error) {
        console.error('删除配置失败:', error)
        ElMessage.error('删除失败: ' + (error.response?.data?.error || error.message))
      }
    },

    closeModals() {
      this.showAddModal = false
      this.showEditModal = false
      this.isEditing = false
      this.editingConfigId = null
      this.resetForm()
    },

    formatDateTime(dateString) {
      if (!dateString) return ''
      const date = new Date(dateString)
      return date.toLocaleString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      })
    }
  }
}
</script>

<style scoped>
.generation-config {
  padding: 20px;
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
  text-align: center;
  margin-bottom: 40px;
}

.page-header h1 {
  font-size: 2.5rem;
  color: #2c3e50;
  margin-bottom: 10px;
}

.page-header p {
  color: #666;
  font-size: 1.1rem;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  flex-wrap: wrap;
  gap: 15px;
}

.section-header h2 {
  color: #2c3e50;
  margin: 0;
}

.add-config-btn {
  background: #27ae60;
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  transition: background 0.3s ease;
}

.add-config-btn:hover {
  background: #219a52;
}

.configs-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(650px, 1fr));
  gap: 20px;
}

.config-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  border: 1px solid #e1e8ed;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.config-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 15px rgba(0, 0, 0, 0.15);
}

.config-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 2px solid #f0f0f0;
}

.config-title h3 {
  color: #2c3e50;
  margin: 0 0 10px 0;
  font-size: 1.3rem;
}

.config-badges {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.status-badge, .mode-badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
}

.status-badge {
  background: #ffebee;
  color: #d32f2f;
}

.status-badge.active {
  background: #e8f5e8;
  color: #388e3c;
}

.mode-badge {
  background: #e3f2fd;
  color: #1976d2;
}

.config-actions {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.enable-btn, .edit-btn, .delete-btn {
  padding: 6px 12px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.85rem;
  transition: background 0.3s ease;
}

.enable-btn {
  background: #27ae60;
  color: white;
}

.enable-btn:hover {
  background: #219a52;
}

.edit-btn {
  background: #f39c12;
  color: white;
}

.edit-btn:hover {
  background: #e67e22;
}

.delete-btn {
  background: #e74c3c;
  color: white;
}

.delete-btn:hover {
  background: #c0392b;
}

.config-details {
  margin-top: 15px;
}

.detail-section {
  margin-bottom: 15px;
  padding: 12px;
  background: #f8f9fa;
  border-radius: 8px;
}

.detail-section h4 {
  margin: 0 0 10px 0;
  color: #2c3e50;
  font-size: 1rem;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 6px 0;
  font-size: 0.9rem;
}

.detail-item label {
  color: #666;
  font-weight: 500;
}

.detail-item span {
  color: #2c3e50;
  font-weight: 600;
}

.detail-item span.enabled {
  color: #27ae60;
}

.detail-item span.disabled {
  color: #e74c3c;
}

.config-meta {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 12px;
  margin-top: 15px;
  padding-top: 15px;
  border-top: 1px solid #e0e0e0;
}

.meta-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.meta-item label {
  font-size: 0.85rem;
  color: #666;
  font-weight: 600;
}

.meta-item span {
  color: #2c3e50;
  font-size: 0.9rem;
}

.empty-state {
  text-align: center;
  padding: 80px 20px;
  color: #666;
}

.empty-icon {
  font-size: 4rem;
  margin-bottom: 20px;
}

.empty-state h3 {
  color: #2c3e50;
  margin-bottom: 10px;
}

.add-first-config-btn {
  background: #3498db;
  color: white;
  border: none;
  padding: 15px 30px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1.1rem;
  transition: background 0.3s ease;
  margin-top: 20px;
}

.add-first-config-btn:hover {
  background: #2980b9;
}

.config-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 12px;
  padding: 0;
  max-width: 700px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 30px;
  border-bottom: 1px solid #eee;
}

.modal-header h3 {
  margin: 0;
  color: #2c3e50;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #666;
}

.modal-body {
  padding: 30px;
}

.form-section {
  margin-bottom: 25px;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 8px;
}

.form-section h4 {
  margin: 0 0 15px 0;
  color: #2c3e50;
  font-size: 1.1rem;
}

.form-group {
  margin-bottom: 18px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #2c3e50;
  font-size: 0.9rem;
}

.form-input, .form-select {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 0.95rem;
  transition: border-color 0.3s ease;
}

.form-input:focus, .form-select:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 2px rgba(52, 152, 219, 0.2);
}

.field-hint {
  margin-top: 5px;
  font-size: 0.8rem;
  color: #666;
  font-style: italic;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  user-select: none;
}

.checkbox-label input[type="checkbox"] {
  width: auto;
}

.checkbox-hint {
  margin-top: 5px;
  font-size: 0.8rem;
  color: #666;
  font-style: italic;
}

.required {
  color: #e74c3c;
}

.modal-actions {
  display: flex;
  gap: 15px;
  justify-content: flex-end;
  margin-top: 30px;
}

.cancel-btn {
  background: #95a5a6;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 6px;
  cursor: pointer;
}

.cancel-btn:hover {
  background: #7f8c8d;
}

.confirm-btn {
  background: #27ae60;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 6px;
  cursor: pointer;
}

.confirm-btn:hover:not(:disabled) {
  background: #219a52;
}

.confirm-btn:disabled {
  background: #bdc3c7;
  cursor: not-allowed;
}

@media (max-width: 768px) {
  .configs-grid {
    grid-template-columns: 1fr;
  }

  .config-header {
    flex-direction: column;
    gap: 15px;
    align-items: flex-start;
  }

  .form-row {
    grid-template-columns: 1fr;
  }

  .detail-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 5px;
  }
}
</style>
