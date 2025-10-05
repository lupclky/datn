import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface LockFeature {
  id?: number;
  name: string;
  description: string;
  isActive: boolean;
}

@Injectable({
  providedIn: 'root'
})
export class LockFeatureService {
  private apiUrl = `${environment.apiUrl}/lock-features`;

  constructor(private http: HttpClient) {}

  getAllFeatures(): Observable<LockFeature[]> {
    return this.http.get<LockFeature[]>(this.apiUrl);
  }

  getFeatureById(id: number): Observable<LockFeature> {
    return this.http.get<LockFeature>(`${this.apiUrl}/${id}`);
  }

  createFeature(feature: LockFeature): Observable<LockFeature> {
    return this.http.post<LockFeature>(this.apiUrl, feature);
  }

  updateFeature(id: number, feature: LockFeature): Observable<LockFeature> {
    return this.http.put<LockFeature>(`${this.apiUrl}/${id}`, feature);
  }

  deleteFeature(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }
}

