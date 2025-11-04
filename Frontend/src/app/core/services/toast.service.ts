import { Injectable } from '@angular/core';
import { MessageService } from 'primeng/api';

@Injectable({
  providedIn: 'root'
})
export class ToastService {

  constructor(
    private readonly messageService : MessageService
  ) { }

  success(content : string){
    this.messageService.add({ severity: 'success', summary: 'Thành công', detail: content});
  }

  showSuccess(summary: string, detail: string) {
    this.messageService.add({ severity: 'success', summary: summary, detail: detail});
  }

  fail(content : string){
    this.messageService.add({ severity: 'error', summary: 'Thất bại', detail: content});
  }

  showError(summary: string, detail: string) {
    this.messageService.add({ severity: 'error', summary: summary, detail: detail});
  }

  warn(content: string) {
    this.messageService.add({ severity: 'warn', summary: 'Cảnh báo', detail: content });
  }

  accountBlocked(content : string){
    this.messageService.add({ 
      severity: 'error', 
      summary: 'Tài khoản bị khóa', 
      detail: content,
      life: 5000,
      sticky: true
    });
  }
}
