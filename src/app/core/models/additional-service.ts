export interface AdditionalService {
  id: number;
  name: string;
  description?: string;
  price: number;
  available: boolean;
  itemType: 'property' | 'vehicle';
  itemId: number;
}
