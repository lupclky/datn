export interface NewsDto {
  id?: number;
  title: string;
  content: string;
  summary?: string;
  thumbnail?: string;
  author?: string;
  category?: string;
  status: 'DRAFT' | 'PUBLISHED' | 'ARCHIVED' | 'ACTIVE' | 'INACTIVE';
  viewCount?: number;
  tags?: string;
  publishedAt?: Date;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface NewsPage {
  content: NewsDto[];
  totalElements: number;
  totalPages: number;
  size: number;
  number: number;
  first: boolean;
  last: boolean;
}

