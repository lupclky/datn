import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { CardModule } from 'primeng/card';

export interface LinkPreview {
  url: string;
  title?: string;
  description?: string;
  image?: string;
  favicon?: string;
  siteName?: string;
}

@Component({
  selector: 'app-link-preview-card',
  standalone: true,
  imports: [CommonModule, CardModule],
  templateUrl: './link-preview-card.component.html',
  styleUrl: './link-preview-card.component.scss'
})
export class LinkPreviewCardComponent {
  @Input() linkData!: LinkPreview;
  @Input() compact: boolean = false; // Chế độ compact (nhỏ gọn)

  openLink(): void {
    if (this.linkData?.url) {
      window.open(this.linkData.url, '_blank');
    }
  }

  getDomain(url: string): string {
    try {
      const domain = new URL(url).hostname;
      return domain.replace('www.', '');
    } catch {
      return url;
    }
  }

  getDefaultImage(): string {
    return 'assets/images/link-placeholder.png';
  }
}

