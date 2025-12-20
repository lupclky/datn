import { AfterViewInit, Component, HostListener, OnInit } from '@angular/core';
import { Router, RouterOutlet, NavigationEnd } from '@angular/router';
import { AppHeaderComponent } from '../app-header/app-header.component';
import { AppNavbarComponent } from '../app-navbar/app-navbar.component';
// import { HomeComponent } from '../../../features/components/home/home.component';
import { MatInputModule } from '@angular/material/input';
import { AppFooterComponent } from '../app-footer/app-footer.component';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { BlockUIModule } from 'primeng/blockui';
import { BaseComponent } from '../../commonComponent/base.component';
import { LoadingService } from '../../services/loading.service';
import { takeUntil, tap, filter } from 'rxjs';
import { AiChatbotComponent } from '../ai-chatbot/ai-chatbot.component';
import { ScrollToTopComponent } from '../../../shared/components/scroll-to-top/scroll-to-top.component';
import { AppBottomNavComponent } from '../app-bottom-nav/app-bottom-nav.component';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-app-layout',
  standalone: true,
  imports: [
    CommonModule,
    RouterOutlet,
    AppHeaderComponent,
    MatInputModule,
    AppNavbarComponent,
    AppFooterComponent,
    ProgressSpinnerModule,
    BlockUIModule,
    AiChatbotComponent,
    ScrollToTopComponent,
    AppBottomNavComponent
  ],
  templateUrl: './app-layout.component.html',
  styleUrl: './app-layout.component.scss'
})
export class AppLayoutComponent extends BaseComponent implements AfterViewInit, OnInit {
  public blockedUi: boolean = false;
  private lastScrollTop = 0;
  public isHeaderHidden = false;
  public roleId: number = 0;
  public isSidebarOpen: boolean = true;

  constructor(
    private loadingService: LoadingService,
    private router: Router
  ) {
    super();
    // Get roleId from localStorage
    if (typeof localStorage !== 'undefined') {
      const userInfo = localStorage.getItem('userInfor');
      if (userInfo) {
        try {
          const parsed = JSON.parse(userInfo);
          this.roleId = parseInt(parsed.role_id || parsed.role?.id || '0');
        } catch (e) {
          this.roleId = 0;
        }
      }
    }
  }

  ngOnInit(): void {
    // Update roleId first
    this.updateRoleId();
    
    this.router.events.pipe(
      filter((event): event is NavigationEnd => event instanceof NavigationEnd),
      tap((event: NavigationEnd) => {
        window.scrollTo(0, 0);
        // Update roleId on navigation
        this.updateRoleId();
        
        // Small delay to ensure roleId is updated
        setTimeout(() => {
          this.handleRoleBasedRedirect(event.url);
        }, 0);
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
    
    // Check initial route and redirect if needed after a small delay
    setTimeout(() => {
      const currentUrl = this.router.url;
      this.handleRoleBasedRedirect(currentUrl);
    }, 100);
  }

  private handleRoleBasedRedirect(url: string): void {
    // Only redirect if user is on Home page or root
    if (url === '/Home' || url === '/' || url === '') {
      if (this.roleId === 2) {
        // Admin -> Dashboard
        this.router.navigate(['/admin/dashboard'], { replaceUrl: true });
      } else if (this.roleId === 3) {
        // Staff -> Order Management
        this.router.navigate(['/orderManage'], { replaceUrl: true });
      }
    }
  }

  private updateRoleId(): void {
    if (typeof localStorage !== 'undefined') {
      const userInfo = localStorage.getItem('userInfor');
      if (userInfo) {
        try {
          const parsed = JSON.parse(userInfo);
          this.roleId = parseInt(parsed.role_id || parsed.role?.id || '0');
        } catch (e) {
          this.roleId = 0;
        }
      } else {
        this.roleId = 0;
      }
    }
  }

  ngAfterViewInit(): void {
    this.loadingService.loading$.pipe(
      tap((loading) => {
        this.blockedUi = loading;
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }

  @HostListener('window:scroll', ['$event'])
  onWindowScroll() {
    // Don't hide header for admin or staff users (roleId == 2 or 3)
    if (this.roleId === 2 || this.roleId === 3) {
      this.isHeaderHidden = false;
      return;
    }

    const st = window.pageYOffset || document.documentElement.scrollTop;
    // Hide header only when scrolling down and past the header's height
    if (st > this.lastScrollTop && st > 150) {
      this.isHeaderHidden = true;
    } else {
      this.isHeaderHidden = false;
    }
    this.lastScrollTop = st <= 0 ? 0 : st;
  }

  onSidebarToggle(isOpen: boolean) {
    this.isSidebarOpen = isOpen;
  }
}
