export interface NewsDto {
  id: number;
  title: string;
  content: string;
  summary: string;
  author: string;
  category: string;
  status: 'DRAFT' | 'PUBLISHED' | 'ARCHIVED';
  featured_image: string;
  views: number;
  published_at: string;
  created_at: string;
  updated_at: string;
}

export interface NewsListResponse {
  news_list: NewsDto[];
  total_pages: number;
}

export interface NewsCreateRequest {
  title: string;
  content: string;
  summary: string;
  author: string;
  category: string;
  status: 'DRAFT' | 'PUBLISHED' | 'ARCHIVED';
  featured_image: string;
}

