import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { UserService } from '../../../core/services/user.service';
import { ToastService } from '../../../core/services/toast.service';
import { ToastModule } from 'primeng/toast';
import { MessageService } from 'primeng/api';

@Component({
  selector: 'app-user-management',
  standalone: true,
  imports: [CommonModule, FormsModule, ToastModule],
  providers: [MessageService, ToastService],
  templateUrl: './user-management.component.html',
  styleUrls: ['./user-management.component.scss']
})
export class UserManagementComponent implements OnInit {
  users: any[] = [];
  filteredUsers: any[] = [];
  searchKeyword = '';
  isLoading = false;
  
  showModal = false;
  isEditing = false;
  currentUser: any = {};
  originalRoleId: number = 0;

  constructor(
    private userService: UserService,
    private toastService: ToastService
  ) {}
  
  ngOnInit(): void {
    this.currentUser = this.getEmptyUser();
    this.loadUsers();
  }
  
  getEmptyUser() {
    return {
      fullname: '',
      phone_number: '',
      password: '',
      retypePassword: '',
      email: '',
      address: '',
      role_id: 2,
      is_active: true
    };
  }

  loadUsers(): void {
    this.isLoading = true;
    this.userService.getAllUsers().subscribe({
      next: (response: any) => {
        this.users = response || [];
        this.filteredUsers = this.users;
        this.isLoading = false;
      },
      error: (error: any) => {
        console.error('Error loading users:', error);
        this.toastService.showError('Không thể tải danh sách người dùng');
        this.isLoading = false;
      }
    });
  }

  searchUsers(): void {
    if (!this.searchKeyword.trim()) {
      this.filteredUsers = this.users;
      return;
    }

    const keyword = this.searchKeyword.toLowerCase();
    this.filteredUsers = this.users.filter((user: any) => 
      (user.fullname && user.fullname.toLowerCase().includes(keyword)) ||
      (user.phone_number && user.phone_number.includes(keyword)) ||
      (user.email && user.email.toLowerCase().includes(keyword))
    );
  }

  formatDate(date: any): string {
    if (!date) return 'N/A';
    const d = new Date(date);
    return `${d.getDate().toString().padStart(2, '0')}/${(d.getMonth() + 1).toString().padStart(2, '0')}/${d.getFullYear()}`;
  }

  openAddUserModal(): void {
    console.log('Opening modal...');
    this.isEditing = false;
    this.currentUser = this.getEmptyUser();
    this.showModal = true;
    console.log('showModal:', this.showModal);
  }

  editUser(user: any): void {
    console.log('Editing user:', user);
    this.isEditing = true;
    this.currentUser = { 
      ...user,
      role_id: user.role?.id || 2  // Extract role ID from role object
    };
    this.originalRoleId = user.role?.id || 2;  // Store original role for comparison
    this.showModal = true;
  }
  
  closeModal(): void {
    this.showModal = false;
    this.currentUser = this.getEmptyUser();
    this.originalRoleId = 0;
  }
  
  saveUser(): void {
    if (!this.isEditing) {
      // Validate for create
      if (!this.currentUser.fullname || !this.currentUser.phone_number || !this.currentUser.password || !this.currentUser.retypePassword) {
        this.toastService.showError('Vui lòng nhập đầy đủ thông tin bắt buộc');
        return;
      }
      
      if (this.currentUser.password !== this.currentUser.retypePassword) {
        this.toastService.showError('Mật khẩu không khớp');
        return;
      }
      
      this.createUser();
    } else {
      // Validate for update
      if (!this.currentUser.fullname || !this.currentUser.phone_number) {
        this.toastService.showError('Vui lòng nhập đầy đủ thông tin bắt buộc');
        return;
      }
      
      if (this.currentUser.id) {
        this.updateUser();
      }
    }
  }
  
  createUser(): void {
    console.log('Creating user:', this.currentUser);
    
    const userData: any = {
      fullname: this.currentUser.fullname,
      phone_number: this.currentUser.phone_number,
      password: this.currentUser.password,
      retype_password: this.currentUser.retypePassword,
      email: this.currentUser.email || '',
      address: this.currentUser.address || ''
    };
    
    // Add role_id if admin wants to set specific role
    if (this.currentUser.role_id) {
      userData.role_id = this.currentUser.role_id;
    }
    
    this.userService.register(userData).subscribe({
      next: (response: any) => {
        console.log('User created:', response);
        this.toastService.showSuccess('Thêm người dùng thành công');
        this.closeModal();
        this.loadUsers();
      },
      error: (error: any) => {
        console.error('Error creating user:', error);
        const errorMsg = error?.error?.message || 'Không thể thêm người dùng';
        this.toastService.showError(errorMsg);
      }
    });
  }
  
  updateUser(): void {
    if (!this.currentUser.id) return;
    
    console.log('Updating user:', this.currentUser);
    
    // Check if role changed
    const roleChanged = this.currentUser.role_id !== this.originalRoleId;
    
    if (roleChanged) {
      console.log('Role changed, calling changeRole API');
      this.changeUserRole(this.currentUser.id, this.currentUser.role_id).subscribe({
        next: () => {
          // After role is changed, update other user info
          this.updateUserInfo();
        },
        error: (error: any) => {
          console.error('Error changing role:', error);
          this.toastService.showError('Không thể thay đổi vai trò');
        }
      });
    } else {
      // Only update user info if role didn't change
      this.updateUserInfo();
    }
  }
  
  updateUserInfo(): void {
    const updateData = {
      id: this.currentUser.id,  // Required for updateUser service method
      fullname: this.currentUser.fullname,
      phone_number: this.currentUser.phone_number,
      email: this.currentUser.email || '',
      address: this.currentUser.address || ''
    };
    
    console.log('Update data:', updateData);
    
    this.userService.updateUser(updateData).subscribe({
      next: (response: any) => {
        this.toastService.showSuccess('Cập nhật người dùng thành công');
        this.closeModal();
        this.loadUsers();
      },
      error: (error: any) => {
        console.error('Error updating user:', error);
        this.toastService.showError('Không thể cập nhật người dùng');
      }
    });
  }
  
  changeUserRole(userId: number, roleId: number) {
    return this.userService.changeRoleUser(roleId, userId);
  }

  toggleUserStatus(user: any): void {
    const action = user.is_active ? 'khóa' : 'mở khóa';
    const actionText = user.is_active ? 'Lock' : 'Unlock';
    
    if (confirm(`Bạn có chắc muốn ${action} tài khoản ${user.fullname}?`)) {
      this.userService.changeActive(user.id, !user.is_active).subscribe({
        next: (response: any) => {
          this.toastService.showSuccess(`Đã ${action} tài khoản thành công`);
          this.loadUsers();
        },
        error: (error: any) => {
          console.error('Error toggling user status:', error);
          this.toastService.showError('Không thể thay đổi trạng thái tài khoản');
        }
      });
    }
  }

  deleteUser(user: any): void {
    if (confirm(`Bạn có chắc muốn xóa người dùng ${user.fullname}?`)) {
      this.userService.deleteUser(user.id).subscribe({
        next: (response: any) => {
          this.toastService.showSuccess('Đã xóa người dùng thành công');
          this.loadUsers();
        },
        error: (error: any) => {
          console.error('Error deleting user:', error);
          this.toastService.showError('Không thể xóa người dùng');
        }
      });
    }
  }
}

