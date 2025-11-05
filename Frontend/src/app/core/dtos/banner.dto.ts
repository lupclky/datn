export interface BannerDto {
  id?: number;
  title: string;
  description?: string;
  image_url: string;
  button_text?: string;
  button_link?: string;
  button_style?: string;
  display_order?: number;
  is_active?: boolean;
  start_date?: string | null;
  end_date?: string | null;
  created_at?: string;
  updated_at?: string;
}

export interface BannerResponse {
  message: string;
  banner?: BannerDto;
}

export interface BannerListResponse {
  message: string;
  banners: BannerDto[];
  total: number;
}


