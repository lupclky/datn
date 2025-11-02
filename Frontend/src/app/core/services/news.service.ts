import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { environment } from '../../../environments/environment';
import { NewsDto, NewsPage } from '../dtos/news.dto';

@Injectable({
  providedIn: 'root'
})
export class NewsService {
  private apiNewsUrl = `${environment.apiUrl}/news`;

  constructor(private http: HttpClient) { }

  getAllNews(keyword: string, status: string, page: number, limit: number): Observable<NewsPage> {
    let params = new HttpParams()
      .set('page', page.toString())
      .set('limit', limit.toString());
    
    if (status) {
      params = params.set('status', status);
    }
    if (keyword) {
      params = params.set('keyword', keyword);
    }
    
    return this.http.get<NewsPage>(this.apiNewsUrl, { params });
  }

  getNewsList(page: number, size: number, status?: string, keyword?: string): Observable<NewsPage> {
    let params = new HttpParams()
      .set('page', page.toString())
      .set('limit', size.toString());
    
    if (status) {
      params = params.set('status', status);
    }
    if (keyword) {
      params = params.set('keyword', keyword);
    }
    
    return this.http.get<NewsPage>(this.apiNewsUrl, { params });
  }

  getNewsById(id: number): Observable<NewsDto> {
    return this.http.get<NewsDto>(`${this.apiNewsUrl}/${id}`);
  }

  createNews(news: NewsDto): Observable<NewsDto> {
    return this.http.post<NewsDto>(this.apiNewsUrl, news);
  }

  updateNews(id: number, news: NewsDto): Observable<NewsDto> {
    return this.http.put<NewsDto>(`${this.apiNewsUrl}/${id}`, news);
  }

  deleteNews(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiNewsUrl}/${id}`);
  }

  publishNews(id: number): Observable<NewsDto> {
    return this.http.put<NewsDto>(`${this.apiNewsUrl}/${id}/publish`, {});
  }

  saveDraft(news: NewsDto): Observable<NewsDto> {
    return this.http.put<NewsDto>(`${this.apiNewsUrl}/draft`, news);
  }
}

