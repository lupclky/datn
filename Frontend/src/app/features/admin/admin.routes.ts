import { Routes } from '@angular/router';
import { AdminDashboardComponent } from './admin-dashboard/admin-dashboard.component';
import { OrderDetailComponent } from '../components/order-detail/order-detail.component';
import { ReturnManageComponent } from '../components/return-manage/return-manage.component';
import { FeatureManageComponent } from '../components/feature-manage/feature-manage.component';

export const ADMIN_ROUTES: Routes = [
  {
    path: 'dashboard',
    component: AdminDashboardComponent
  },
  {
    path: 'orders/:id',
    component: OrderDetailComponent
  },
  {
    path: 'returns',
    component: ReturnManageComponent
  },
  {
    path: 'features',
    component: FeatureManageComponent
  },
  // ... existing code ...
]; 