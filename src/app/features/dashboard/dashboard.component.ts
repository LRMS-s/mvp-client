import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { DashboardService } from './services/dashboard.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss',
})
export class DashboardComponent implements OnInit {
  stats: any = {};
  loading = true;
  error = false;

  constructor(private dashboardService: DashboardService) {}

  ngOnInit(): void {
    // this.loadDashboardData();
  }

  loadDashboardData(): void {
    this.loading = true;
    this.dashboardService.getDashboardStats().subscribe({
      next: (data) => {
        this.stats = data;
        this.loading = false;
      },
      error: (err) => {
        console.error('Error loading dashboard data', err);
        this.error = true;
        this.loading = false;
      },
    });
  }
}
