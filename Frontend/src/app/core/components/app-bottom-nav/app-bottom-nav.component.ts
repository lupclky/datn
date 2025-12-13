import { Component, OnInit, ViewChild, ElementRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { DetailProductService } from '../../services/detail-product.service';
import { ProductService } from '../../services/product.service';
import { ProductFromCartDto } from '../../dtos/ProductFromCart.dto';
import { filter, tap } from 'rxjs/operators';

@Component({
  selector: 'app-bottom-nav',
  standalone: true,
  imports: [CommonModule, RouterModule, FormsModule],
  templateUrl: './app-bottom-nav.component.html',
  styleUrls: ['./app-bottom-nav.component.scss']
})
export class AppBottomNavComponent implements OnInit {
  isSearchOpen: boolean = false;
  searchKeyword: string = '';
  cartCount: number = 0;
  
  @ViewChild('searchInput') searchInput!: ElementRef;

  constructor(
    private router: Router,
    private detailProductService: DetailProductService,
    private productService: ProductService
  ) {}

  ngOnInit(): void {
    // Sync cart count
    this.detailProductService.quantityProductsInCart.pipe(
      filter((quantity: number) => quantity !== null && quantity !== undefined),
      tap((quantity: number) => {
        this.cartCount = quantity;
      })
    ).subscribe();

    // Initial cart load if token exists
    if (localStorage.getItem('token')) {
      this.productService.getProductFromCart().pipe(
        filter((product: ProductFromCartDto) => !!product),
        tap((product: ProductFromCartDto) => {
          this.cartCount = product.totalCartItems;
        })
      ).subscribe();
    }
  }

  toggleSearch() {
    this.isSearchOpen = !this.isSearchOpen;
    if (this.isSearchOpen) {
      setTimeout(() => {
        this.searchInput?.nativeElement.focus();
      }, 100);
    }
  }

  onSearch() {
    if (this.searchKeyword.trim()) {
      this.router.navigate(['/allProduct'], { 
        queryParams: { 
          keyword: this.searchKeyword.trim() 
        } 
      });
      this.toggleSearch();
      this.searchKeyword = '';
    }
  }
}


