import { Component, OnInit, signal, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../../environments/environment.development';
import { finalize } from 'rxjs/operators';

interface LogEntry {
  message: string;
  type: 'info' | 'success' | 'error' | 'warning';
  timestamp: Date;
}

@Component({
  selector: 'app-ai-management',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './ai-management.component.html',
  styleUrls: ['./ai-management.component.scss']
})
export class AiManagementComponent implements OnInit, OnDestroy {
  isLoading = signal(false);
  isIndexing = signal(false);
  documentCount = signal(0);
  status = signal('not_initialized'); // 'initialized' | 'not_initialized' | 'indexing'
  lastUpdated = signal<Date | null>(null);
  logs = signal<LogEntry[]>([]);
  
  // Progress tracking
  progress = signal(0);
  currentAction = signal('');
  
  private apiUrl = environment.apiUrl;
  private pollInterval: any;

  constructor(private http: HttpClient) {}

  ngOnInit() {
    this.checkAIStatus();
  }

  ngOnDestroy() {
    this.stopPolling();
  }

  addLog(message: string, type: 'info' | 'success' | 'error' | 'warning' = 'info') {
    // Avoid duplicate logs if polling same status
    const currentLogs = this.logs();
    if (currentLogs.length > 0 && currentLogs[0].message === message) {
        return; 
    }
    
    this.logs.update(logs => [
      { message, type, timestamp: new Date() },
      ...logs
    ]);
  }

  clearLogs() {
    this.logs.set([]);
  }

  checkAIStatus() {
    // Don't set global loading spinner if we are just polling
    if (!this.pollInterval) {
        this.isLoading.set(true);
    }
    
    this.http.get<{
        success: boolean; 
        status: string; 
        documentCount: number; 
        isIndexing?: boolean;
        currentAction?: string;
        progress?: number;
    }>(`${this.apiUrl}/ai/initialize/status`)
      .pipe(finalize(() => {
          if (!this.pollInterval) this.isLoading.set(false);
      }))
      .subscribe({
        next: (response) => {
          if (response.success) {
            this.status.set(response.status); // 'indexing' or 'idle' -> map to badge
            this.documentCount.set(response.documentCount);
            this.lastUpdated.set(new Date());

            if (response.isIndexing) {
                this.isIndexing.set(true);
                this.currentAction.set(response.currentAction || 'Đang xử lý...');
                this.progress.set(response.progress || 0);
                
                // If not already polling, start polling
                if (!this.pollInterval) {
                    this.startPolling();
                }
            } else {
                // If finished indexing
                if (this.isIndexing()) {
                    this.isIndexing.set(false);
                    this.progress.set(100);
                    this.currentAction.set('Hoàn tất.');
                    this.addLog('✅ Quá trình index hoàn tất.', 'success');
                    this.stopPolling();
                }
                this.isIndexing.set(false);
            }
          }
        },
        error: (err) => {
          // Silent fail on poll, verbose on manual check
          if (!this.pollInterval) {
             this.addLog(`Lỗi khi kiểm tra trạng thái: ${err.message}`, 'error');
          }
        }
      });
  }

  startPolling() {
      if (this.pollInterval) return;
      this.pollInterval = setInterval(() => {
          this.checkAIStatus();
      }, 2000); // Poll every 2 seconds
  }

  stopPolling() {
      if (this.pollInterval) {
          clearInterval(this.pollInterval);
          this.pollInterval = null;
      }
  }

  initializeAI() {
    if (!confirm('Bạn có chắc chắn muốn khởi tạo lại database AI? Dữ liệu cũ sẽ bị xóa và quá trình này có thể mất vài phút.')) {
      return;
    }

    this.isLoading.set(true);
    this.addLog('Đang gửi yêu cầu khởi tạo...', 'info');

    this.http.post<{success: boolean; message: string}>(`${this.apiUrl}/ai/initialize/index-all`, {})
      .pipe(finalize(() => this.isLoading.set(false)))
      .subscribe({
        next: (response) => {
          if (response.success) {
            this.addLog('🚀 Đã bắt đầu quá trình index (chạy nền).', 'success');
            this.isIndexing.set(true);
            this.currentAction.set('Khởi động...');
            this.progress.set(0);
            this.startPolling();
          } else {
            this.addLog('❌ Khởi tạo thất bại: ' + response.message, 'error');
          }
        },
        error: (err) => {
          // Handle 403 specifically if needed, though general error is fine
          if (err.status === 403) {
             this.addLog('⛔ Bạn không có quyền thực hiện hành động này (Admin only).', 'error');
          } else {
             this.addLog(`❌ Lỗi server: ${err.message}`, 'error');
          }
        }
      });
  }

  clearDatabase() {
    if (!confirm('CẢNH BÁO: Hành động này sẽ xóa toàn bộ dữ liệu vector. Bạn có chắc chắn không?')) {
      return;
    }

    this.isLoading.set(true);
    this.addLog('Đang xóa database...', 'warning');

    this.http.delete<{success: boolean; message: string}>(`${this.apiUrl}/ai/initialize/clear-index`)
      .pipe(finalize(() => this.isLoading.set(false)))
      .subscribe({
        next: (response) => {
          if (response.success) {
            this.addLog('🗑️ Đã xóa sạch database.', 'success');
            this.checkAIStatus();
          }
        },
        error: (err) => {
          if (err.status === 403) {
             this.addLog('⛔ Bạn không có quyền xóa database (Admin only).', 'error');
          } else {
             this.addLog(`Lỗi khi xóa database: ${err.message}`, 'error');
          }
        }
      });
  }
}
