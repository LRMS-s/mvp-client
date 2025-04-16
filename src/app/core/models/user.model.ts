export enum UserType {
  CLIENT = 'client',
  STAFF = 'staff',
  ADMIN = 'admin'
}

export enum UserStatus {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  SUSPENDED = 'suspended',
  PENDING_VERIFICATION = 'pending_verification'
}

export interface User {
  id: number;
  username: string;
  email: string;
  firstName: string;
  lastName: string;
  phone?: string;
  address?: string;
  city?: string;
  state?: string;
  country?: string;
  postalCode?: string;
  dateOfBirth?: Date;
  userType: UserType;
  status: UserStatus;
  profileImageUrl?: string;
  lastLogin?: Date;
  createdAt: Date;
  updatedAt: Date;
  fullName?: string;
  isActive?: boolean;
}
