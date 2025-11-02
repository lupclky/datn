import { Routes } from '@angular/router';
import { AdminLayoutComponent } from './admin-layout/admin-layout.component';
import { ProductManagementComponent } from './product-management/product-management.component';
import { CategoryManagementComponent } from './category-management/category-management.component';
import { NewsManagementComponent } from './news-management/news-management.component';
import { UserManagementComponent } from './user-management/user-management.component';
import { OrderManagementComponent } from './order-management/order-management.component';

export const ADMIN_ROUTES: Routes = [
  {
    path: '',
    component: AdminLayoutComponent,
    children: [
      {
        path: '',
        redirectTo: 'products',
        pathMatch: 'full'
      },
      {
        path: 'products',
        component: ProductManagementComponent
      },
      {
        path: 'categories',
        component: CategoryManagementComponent
      },
      {
        path: 'news',
        component: NewsManagementComponent
      },
      {
        path: 'users',
        component: UserManagementComponent
      },
      {
        path: 'orders',
        component: OrderManagementComponent
      }
    ]
  }
];
