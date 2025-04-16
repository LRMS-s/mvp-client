// src/app/features/clients/components/client-detail.component.ts
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, ActivatedRoute, Router } from '@angular/router';
import { ClientService } from '../services/client.service';
import { Client } from '../../../core/models/client.model';
import { AuthService } from '../../../core/auth/services/auth.service';
import { UserType } from '../../../core/models/user.model';

@Component({
  selector: 'app-client-detail',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './client-detail.component.html',
  styleUrls: ['./client-detail.component.scss'],
})
export class ClientDetailComponent implements OnInit {
  client: Client | null = null;
  isLoading = true;
  error = '';
  isAdmin = false;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private clientService: ClientService,
    private authService: AuthService
  ) {}

  ngOnInit(): void {
    this.checkUserPermissions();
    this.loadClient();
  }

  checkUserPermissions(): void {
    const currentUser = this.authService.getCurrentUser();
    this.isAdmin = currentUser?.userType === UserType.ADMIN;
  }

  loadClient(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (!id) {
      this.error = 'Invalid client ID';
      this.isLoading = false;
      return;
    }

    this.clientService.getClient(+id).subscribe({
      next: (client) => {
        this.client = client;
        this.isLoading = false;
      },
      error: (err) => {
        console.error('Error loading client', err);
        this.error =
          'Failed to load client data. The client may not exist or you may not have permission to view it.';
        this.isLoading = false;
      },
    });
  }

  deleteClient(): void {
    if (
      !this.client ||
      !confirm(
        'Are you sure you want to delete this client? This action cannot be undone.'
      )
    ) {
      return;
    }

    this.clientService.deleteClient(this.client.id).subscribe({
      next: () => {
        this.router.navigate(['/clients']);
      },
      error: (err) => {
        console.error('Error deleting client', err);
        alert('Failed to delete client. Please try again.');
      },
    });
  }
}
