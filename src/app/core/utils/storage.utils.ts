export class StorageUtils {
  static setItem(key: string, value: any): void {
    try {
      const serializedValue = typeof value === 'object'
        ? JSON.stringify(value)
        : String(value);
      localStorage.setItem(key, serializedValue);
    } catch (error) {
      console.error('Error setting localStorage item', error);
    }
  }

  static getItem<T>(key: string): T | null {
    try {
      const item = localStorage.getItem(key);
      if (item === null) return null;

      try {
        return JSON.parse(item) as T;
      } catch {
        return item as unknown as T;
      }
    } catch (error) {
      console.error('Error getting localStorage item', error);
      return null;
    }
  }

  static removeItem(key: string): void {
    try {
      localStorage.removeItem(key);
    } catch (error) {
      console.error('Error removing localStorage item', error);
    }
  }

  static clear(): void {
    try {
      localStorage.clear();
    } catch (error) {
      console.error('Error clearing localStorage', error);
    }
  }
}
