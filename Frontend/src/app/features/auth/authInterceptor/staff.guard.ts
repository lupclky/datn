import { Injectable, PLATFORM_ID, Inject } from '@angular/core';
import { CanActivate, RouterStateSnapshot, ActivatedRouteSnapshot, Router } from '@angular/router';
import { UserService } from '../../../core/services/user.service';
import { Observable, of } from 'rxjs';
import { catchError, map } from 'rxjs/operators';
import { isPlatformBrowser } from '@angular/common';

@Injectable({
  providedIn: 'root'
})
export class StaffGuard implements CanActivate {
  constructor(
    private router: Router,
    private userService: UserService,
    @Inject(PLATFORM_ID) private platformId: Object
  ) {}

  canActivate(
    route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot
  ): Observable<boolean> {
    if (!isPlatformBrowser(this.platformId)) {
      return of(false);
    }
    
    const token = localStorage.getItem("token");
    if (!token) {
      this.router.navigate(['/auth-login']);
      return of(false);
    }

    return this.userService.getInforUser(token).pipe(
      map(userInfor => {
        if (userInfor && userInfor.role) {
          const roleId = userInfor.role.id;
          // Allow STAFF (3) or ADMIN (2)
          if (roleId === 2 || roleId === 3) {
            return true;
          }
        }
        // Not staff or admin, redirect to home
        this.router.navigate(['/Home']);
        return false;
      }),
      catchError((err) => {
        // API error (e.g., token expired), redirect to login
        this.router.navigate(['/auth-login']);
        return of(false);
      })
    );
  }
}

