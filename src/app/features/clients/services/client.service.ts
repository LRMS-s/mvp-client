import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { ApiService } from '../../../core/services/api.service';
import { Client, CreateClientRequest } from '../../../core/models/client.model';

@Injectable({
  providedIn: 'root',
})
export class ClientService {
  private readonly endpoint = 'clients';

  constructor(private apiService: ApiService) {}

  getClients(): Observable<Client[]> {
    return this.apiService.get<Client[]>(`${this.endpoint}`);
  }

  getClient(id: number): Observable<Client> {
    return this.apiService.get<Client>(`${this.endpoint}/${id}`);
  }

  getClientByUserId(userId: number): Observable<Client> {
    return this.apiService.get<Client>(`${this.endpoint}/${userId}`);
  }

  getCurrentClientProfile(): Observable<Client> {
    return this.apiService.get<Client>(`${this.endpoint}/profile`);
  }

  createClient(client: CreateClientRequest): Observable<Client> {
    return this.apiService.post<Client>(this.endpoint, client);
  }

  updateClient(id: number, client: Partial<Client>): Observable<Client> {
    return this.apiService.patch<Client>(`${this.endpoint}/${id}`, client);
  }

  updateClientByUserId(
    userId: number,
    client: Partial<Client>
  ): Observable<Client> {
    return this.apiService.patch<Client>(
      `${this.endpoint}/users/${userId}`,
      client
    );
  }

  deleteClient(id: number): Observable<void> {
    return this.apiService.delete<void>(`${this.endpoint}/${id}`);
  }

  searchClients(query: string): Observable<Client[]> {
    return this.apiService.get<Client[]>(`${this.endpoint}/search`, {
      q: query,
    });
  }

  getClientStatistics(): Observable<any> {
    return this.apiService.get<any>(`${this.endpoint}/statistics`);
  }
}
