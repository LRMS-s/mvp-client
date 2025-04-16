import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'formatDate',
  standalone: true
})
export class FormatDatePipe implements PipeTransform {
  transform(value: Date | string, format: string = 'medium'): string {
    if (!value) {
      return '';
    }

    const date = typeof value === 'string' ? new Date(value) : value;

    if (isNaN(date.getTime())) {
      return '';
    }

    switch (format) {
      case 'short':
        return date.toLocaleDateString();
      case 'medium':
        return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
      case 'long':
        return date.toLocaleDateString(undefined, {
          weekday: 'long',
          year: 'numeric',
          month: 'long',
          day: 'numeric',
          hour: '2-digit',
          minute: '2-digit'
        });
      case 'date':
        return date.toLocaleDateString();
      case 'time':
        return date.toLocaleTimeString();
      case 'relative':
        return this.getRelativeTime(date);
      default:
        return date.toLocaleString();
    }
  }

  private getRelativeTime(date: Date): string {
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffSec = Math.round(diffMs / 1000);

    if (diffSec < 60) {
      return diffSec + ' second' + (diffSec === 1 ? '' : 's') + ' ago';
    }

    const diffMin = Math.round(diffSec / 60);
    if (diffMin < 60) {
      return diffMin + ' minute' + (diffMin === 1 ? '' : 's') + ' ago';
    }

    const diffHour = Math.round(diffMin / 60);
    if (diffHour < 24) {
      return diffHour + ' hour' + (diffHour === 1 ? '' : 's') + ' ago';
    }

    const diffDay = Math.round(diffHour / 24);
    if (diffDay < 30) {
      return diffDay + ' day' + (diffDay === 1 ? '' : 's') + ' ago';
    }

    const diffMonth = Math.round(diffDay / 30);
    if (diffMonth < 12) {
      return diffMonth + ' month' + (diffMonth === 1 ? '' : 's') + ' ago';
    }

    const diffYear = Math.round(diffMonth / 12);
    return diffYear + ' year' + (diffYear === 1 ? '' : 's') + ' ago';
  }
}
