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
    ScrollToTopComponent
  ],
  templateUrl: './app-layout.component.html',
  styleUrl: './app-layout.component.scss'
})
export class AppLayoutComponent extends BaseComponent implements AfterViewInit, OnInit {
  public blockedUi: boolean = false;
  private lastScrollTop = 0;
  public isHeaderHidden = false;
  public roleId: number = 0;

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
    this.router.events.pipe(
      filter(event => event instanceof NavigationEnd),
      tap(() => {
        window.scrollTo(0, 0);
        // Update roleId on navigation
        this.updateRoleId();
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
    
    // Also update on init
    this.updateRoleId();
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
    // Don't hide header for admin users (roleId == 2)
    if (this.roleId === 2) {
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
}
