import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { TableModule } from 'primeng/table';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { DialogModule } from 'primeng/dialog';
import { ToastModule } from 'primeng/toast';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { MessageService, ConfirmationService } from 'primeng/api';
import { LockFeatureService } from '../../../core/services/lock-feature.service';

interface LockFeature {
  id?: number;
  name: string;
  description: string;
  isActive: boolean;
}

@Component({
  selector: 'app-feature-manage',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    TableModule,
    ButtonModule,
    InputTextModule,
    DialogModule,
    ToastModule,
    ConfirmDialogModule
  ],
  providers: [MessageService, ConfirmationService],
  templateUrl: './feature-manage.component.html',
  styleUrls: ['./feature-manage.component.scss']
})
export class FeatureManageComponent implements OnInit {
  features: LockFeature[] = [];
  selectedFeatures: LockFeature[] = [];
  loading: boolean = false;

  // Dialog states
  featureDialog: boolean = false;
  editMode: boolean = false;

  // Form data
  feature: LockFeature = {
    name: '',
    description: '',
    isActive: true
  };

  submitted: boolean = false;

  constructor(
    private lockFeatureService: LockFeatureService,
    private messageService: MessageService,
    private confirmationService: ConfirmationService
  ) {}

  ngOnInit(): void {
    this.loadFeatures();
  }

  loadFeatures(): void {
    this.loading = true;
    this.lockFeatureService.getAllFeatures().subscribe({
      next: (data) => {
        this.features = data;
        this.loading = false;
      },
      error: (error) => {
        this.messageService.add({
          severity: 'error',
          summary: 'Lỗi',
          detail: 'Không thể tải danh sách chức năng'
        });
        this.loading = false;
      }
    });
  }

  openNew(): void {
    this.feature = {
      name: '',
      description: '',
      isActive: true
    };
    this.submitted = false;
    this.editMode = false;
    this.featureDialog = true;
  }

  editFeature(feature: LockFeature): void {
    this.feature = { ...feature };
    this.editMode = true;
    this.featureDialog = true;
  }

  deleteFeature(feature: LockFeature): void {
    this.confirmationService.confirm({
      message: 'Bạn có chắc chắn muốn xóa chức năng "' + feature.name + '"?',
      header: 'Xác nhận xóa',
      icon: 'pi pi-exclamation-triangle',
      accept: () => {
        if (feature.id) {
          this.lockFeatureService.deleteFeature(feature.id).subscribe({
            next: () => {
              this.messageService.add({
                severity: 'success',
                summary: 'Thành công',
                detail: 'Đã xóa chức năng'
              });
              this.loadFeatures();
            },
            error: (error) => {
              this.messageService.add({
                severity: 'error',
                summary: 'Lỗi',
                detail: 'Không thể xóa chức năng'
              });
            }
          });
        }
      }
    });
  }

  hideDialog(): void {
    this.featureDialog = false;
    this.submitted = false;
  }

  saveFeature(): void {
    this.submitted = true;

    if (this.feature.name?.trim()) {
      if (this.editMode && this.feature.id) {
        // Update existing feature
        this.lockFeatureService.updateFeature(this.feature.id, this.feature).subscribe({
          next: () => {
            this.messageService.add({
              severity: 'success',
              summary: 'Thành công',
              detail: 'Đã cập nhật chức năng'
            });
            this.hideDialog();
            this.loadFeatures();
          },
          error: (error) => {
            this.messageService.add({
              severity: 'error',
              summary: 'Lỗi',
              detail: 'Không thể cập nhật chức năng'
            });
          }
        });
      } else {
        // Create new feature
        this.lockFeatureService.createFeature(this.feature).subscribe({
          next: () => {
            this.messageService.add({
              severity: 'success',
              summary: 'Thành công',
              detail: 'Đã tạo chức năng mới'
            });
            this.hideDialog();
            this.loadFeatures();
          },
          error: (error) => {
            this.messageService.add({
              severity: 'error',
              summary: 'Lỗi',
              detail: 'Không thể tạo chức năng mới'
            });
          }
        });
      }
    }
  }
}

