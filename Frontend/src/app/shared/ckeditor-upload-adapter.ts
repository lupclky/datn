import { HttpClient, HttpHeaders } from '@angular/common/http';
import { environment } from '../../environments/environment';

interface UploadResponse {
  fileName: string;
  imageUrl?: string;
}

class CkeditorUploadAdapter {
  constructor(private loader: any, private http: HttpClient) {}

  upload(): Promise<{ default: string }> {
    return this.loader.file.then((file: File) => new Promise((resolve, reject) => {
      if (!file) {
        reject('No file provided for upload');
        return;
      }

      const formData = new FormData();
      formData.append('file', file);

      const token = localStorage.getItem('token');
      const headers = token ? new HttpHeaders({ Authorization: `Bearer ${token}` }) : new HttpHeaders();

      this.http.post<UploadResponse>(`${environment.apiUrl}/news/admin/upload-image`, formData, { headers })
        .subscribe({
          next: (response) => {
            const url = `${environment.apiUrl}/news/images/${response.fileName}`;
            resolve({ default: url });
          },
          error: (error) => reject(error)
        });
    }));
  }

  abort(): void {
    // CKEditor may call abort; no-op since HttpClient request cannot be easily canceled here
  }
}

export function registerCkeditorUploadAdapter(editor: any, http: HttpClient): void {
  if (!editor?.plugins?.get) {
    return;
  }

  const fileRepository = editor.plugins.get('FileRepository');
  if (fileRepository) {
    fileRepository.createUploadAdapter = (loader: any) => new CkeditorUploadAdapter(loader, http);
  }
}
