import { Component, OnInit, signal } from '@angular/core';
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
export class AiManagementComponent implements OnInit {
  isLoading = signal(false);
  documentCount = signal(0);
  status = signal('not_initialized'); // 'initialized' | 'not_initialized'
  lastUpdated = signal<Date | null>(null);
  logs = signal<LogEntry[]>([]);

  private apiUrl = environment.apiUrl;

  constructor(private http: HttpClient) {}

  ngOnInit() {
    this.checkAIStatus();
  }

  addLog(message: string, type: 'info' | 'success' | 'error' | 'warning' = 'info') {
    this.logs.update(currentLogs => [
      { message, type, timestamp: new Date() },
      ...currentLogs
    ]);
  }

  clearLogs() {
    this.logs.set([]);
  }

  checkAIStatus() {
    this.isLoading.set(true);
    this.http.get<{success: boolean; status: string; documentCount: number}>(`${this.apiUrl}/ai/initialize/status`)
      .pipe(finalize(() => this.isLoading.set(false)))
      .subscribe({
        next: (response) => {
          if (response.success) {
            this.status.set(response.status);
            this.documentCount.set(response.documentCount);
            this.lastUpdated.set(new Date());
            this.addLog(`Đã cập nhật trạng thái: ${response.documentCount} documents`, 'info');
          }
        },
        error: (err) => {
          this.addLog(`Lỗi khi kiểm tra trạng thái: ${err.message}`, 'error');
        }
      });
  }

  initializeAI() {
    if (!confirm('Bạn có chắc chắn muốn khởi tạo lại database AI? Dữ liệu cũ sẽ bị xóa và quá trình này có thể mất vài phút.')) {
      return;
    }

    this.isLoading.set(true);
    this.addLog('Bắt đầu quá trình khởi tạo database...', 'info');

    this.http.post<{success: boolean; message: string}>(`${this.apiUrl}/ai/initialize/index-all`, {})
      .pipe(finalize(() => this.isLoading.set(false)))
      .subscribe({
        next: (response) => {
          if (response.success) {
            this.addLog('✅ Khởi tạo thành công!', 'success');
            this.checkAIStatus(); // Refresh status
          } else {
            this.addLog('❌ Khởi tạo thất bại.', 'error');
          }
        },
        error: (err) => {
          this.addLog(`❌ Lỗi server: ${err.message}`, 'error');
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
          this.addLog(`Lỗi khi xóa database: ${err.message}`, 'error');
        }
      });
  }
}

