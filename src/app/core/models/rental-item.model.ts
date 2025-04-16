export enum RentalItemType {
  PROPERTY = 'property',
  VEHICLE = 'vehicle'
}

export enum RentalItemStatus {
  AVAILABLE = 'available',
  RESERVED = 'reserved',
  OCCUPIED = 'occupied',
  MAINTENANCE = 'maintenance',
  INACTIVE = 'inactive'
}

export interface RentalItem {
  id: number;
  name: string;
  description: string;
  itemType: RentalItemType;
  status: RentalItemStatus;
  baseRate: number;
  securityDeposit: number;
  location: string;
  addressLine1?: string;
  addressLine2?: string;
  city?: string;
  state?: string;
  country?: string;
  postalCode?: string;
  latitude?: number;
  longitude?: number;
  mainImageUrl?: string;
  imageUrls?: string[];
  maximumCapacity: number;
  amenities?: Record<string, boolean>;
  isActive: boolean;
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
}
