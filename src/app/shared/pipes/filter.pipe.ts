import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'filter',
  standalone: true
})
export class FilterPipe implements PipeTransform {
  transform<T>(
    items: T[],
    searchText: string,
    properties: (keyof T)[] | ((item: T) => any)[] = []
  ): T[] {
    if (!items || !searchText || !properties.length) {
      return items;
    }

    searchText = searchText.toLowerCase();

    return items.filter(item => {
      return properties.some(property => {
        let value: any;

        if (typeof property === 'function') {
          value = property(item);
        } else {
          value = item[property];

          // Handle nested properties
          if (typeof property === 'string' && property.includes('.')) {
            const props = property.split('.');
            value = props.reduce((obj, prop) => obj?.[prop], item);
          }
        }

        if (value === null || value === undefined) {
          return false;
        }

        // Convert value to string for comparison
        return String(value).toLowerCase().includes(searchText);
      });
    });
  }
}
