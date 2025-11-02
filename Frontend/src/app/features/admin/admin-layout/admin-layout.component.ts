import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';
import { UserService } from '../../../core/services/user.service';

@Component({
  selector: 'app-admin-layout',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './admin-layout.component.html',
  styleUrls: ['./admin-layout.component.scss']
})
export class AdminLayoutComponent implements OnInit {
  isSidebarOpen = true;
  adminName = '';
  currentMenu = '';

  menuItems = [
    { icon: '📦', label: 'Quản lý sản phẩm', route: '/admin/products', id: 'products' },
    { icon: '📁', label: 'Quản lý danh mục', route: '/admin/categories', id: 'categories' },
    { icon: '📰', label: 'Quản lý tin tức', route: '/admin/news', id: 'news' },
    { icon: '👥', label: 'Quản lý người dùng', route: '/admin/users', id: 'users' },
    { icon: '🛒', label: 'Quản lý đơn hàng', route: '/admin/orders', id: 'orders' }
  ];

  constructor(
    private router: Router,
    private userService: UserService
  ) {}

  ngOnInit(): void {
    this.loadAdminInfo();
    this.updateCurrentMenu();
  }

  loadAdminInfo(): void {
    if (typeof localStorage !== 'undefined') {
      const userStr = localStorage.getItem('userInfo');
      if (userStr) {
        const userInfo = JSON.parse(userStr);
        this.adminName = userInfo.fullname || userInfo.phone_number || 'Admin';
      }
    }
  }

  updateCurrentMenu(): void {
    const currentUrl = this.router.url;
    const activeItem = this.menuItems.find(item => currentUrl.includes(item.route));
    this.currentMenu = activeItem?.id || '';
  }

  toggleSidebar(): void {
    this.isSidebarOpen = !this.isSidebarOpen;
  }

  navigateTo(route: string, menuId: string): void {
    this.currentMenu = menuId;
    this.router.navigate([route]);
  }

  logout(): void {
    if (typeof localStorage !== 'undefined') {
      localStorage.removeItem('token');
      localStorage.removeItem('userInfo');
    }
    this.router.navigate(['/auth-login']);
  }
}

