import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { AuthService } from '../../core/auth/services/auth.service';
import { User, UserType } from '../../core/models/user.model';

@Component({
  selector: 'app-sidebar',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './sidebar.component.html',
  styleUrls: ['./sidebar.component.scss'],
})
export class SidebarComponent implements OnInit {
  currentUser: User | null = null;
  isAdmin: boolean = false;
  isClient: boolean = false;
  isStaff: boolean = false;

  constructor(protected authService: AuthService) {}

  ngOnInit(): void {
    this.currentUser = this.authService.getCurrentUser();
    this.isAdmin = this.currentUser?.userType === UserType.ADMIN;
    this.isClient = this.currentUser?.userType === UserType.CLIENT;
    this.isStaff = this.currentUser?.userType === UserType.STAFF;
  }

  logout(): void {
    this.authService.logout();
  }
}
