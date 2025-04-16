// src/app/features/clients/components/client-list.component.ts
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { ClientService } from '../services/client.service';
import { Client } from '../../../core/models/client.model';

@Component({
  selector: 'app-client-list',
  standalone: true,
  imports: [CommonModule, RouterModule, FormsModule],
  templateUrl: './client-list.component.html',
  styleUrls: ['./client-list.component.scss'],
})
export class ClientListComponent implements OnInit {
  clients: Client[] = [];
  filteredClients: Client[] = [];
  isLoading = true;
  searchTerm = '';

  // Pagination
  currentPage = 1;
  itemsPerPage = 10;
  totalItems = 0;

  Math = Math;
  constructor(private clientService: ClientService) {}

  ngOnInit(): void {
    this.loadClients();
  }

  loadClients(): void {
    this.isLoading = true;
    this.clientService.getClients().subscribe({
      next: (clients) => {
        this.clients = clients;
        this.totalItems = clients.length;
        this.applyFilter();
        this.isLoading = false;
      },
      error: (error) => {
        console.error('Error loading clients', error);
        this.isLoading = false;
      },
    });
  }

  applyFilter(): void {
    if (!this.searchTerm.trim()) {
      this.filteredClients = this.clients;
    } else {
      const searchTermLower = this.searchTerm.toLowerCase();
      this.filteredClients = this.clients.filter(
        (client) =>
          client.user.firstName.toLowerCase().includes(searchTermLower) ||
          client.user.lastName.toLowerCase().includes(searchTermLower) ||
          client.user.email.toLowerCase().includes(searchTermLower) ||
          (client.companyName &&
            client.companyName.toLowerCase().includes(searchTermLower))
      );
    }
    this.currentPage = 1; // Reset to first page whenever filter changes
  }

  get paginatedClients(): Client[] {
    const startIndex = (this.currentPage - 1) * this.itemsPerPage;
    return this.filteredClients.slice(
      startIndex,
      startIndex + this.itemsPerPage
    );
  }

  get totalPages(): number {
    return Math.ceil(this.filteredClients.length / this.itemsPerPage);
  }

  changePage(page: number): void {
    if (page >= 1 && page <= this.totalPages) {
      this.currentPage = page;
    }
  }
}
