import { User } from './user.model';

export interface Client extends User {
  id: number;
  companyName?: string;
  nationality?: string;
  taxId?: string;
  clientSince: Date;
  clientSource?: string;
  notes?: string;
}

export interface CreateClientRequest {
  client: {
    companyName?: string;
    nationality?: string;
    taxId?: string;
    clientSource?: string;
    notes?: string;
  };
  user: {
    username: string;
    email: string;
    password: string;
    firstName: string;
    lastName: string;
    phone?: string;
    address?: string;
    city?: string;
    state?: string;
    country?: string;
    postalCode?: string;
    userType: string;
  };
}
