import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';

export interface Column {
  key: string;
  label: string;
  sortable?: boolean;
  format?: (value: any) => string;
}

export interface SortEvent {
  column: string;
  direction: 'asc' | 'desc';
}
@Component({
  selector: 'app-data-table',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './data-table.component.html',
  styleUrl: './data-table.component.scss',
})
export class DataTableComponent {
  @Input() columns: Column[] = [];
  @Input() data: any[] = [];
  @Input() loading = false;
  @Input() sortable = true;
  @Input() pagination = true;
  @Input() pageSize = 10;
  @Input() currentPage = 1;
  @Input() totalItems = 0;
  @Input() emptyMessage = 'No data available';
  @Input() selectable = false;
  @Input() selectedItems: any[] = [];

  @Output() sort = new EventEmitter<SortEvent>();
  @Output() page = new EventEmitter<number>();
  @Output() selectItem = new EventEmitter<any>();
  @Output() selectAll = new EventEmitter<boolean>();
  @Output() rowClick = new EventEmitter<any>();

  sortColumn = '';
  sortDirection: 'asc' | 'desc' = 'asc';
  allSelected = false;

  Math = Math;
  onSort(column: Column): void {
    if (!column.sortable || !this.sortable) return;

    if (this.sortColumn === column.key) {
      this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
    } else {
      this.sortColumn = column.key;
      this.sortDirection = 'asc';
    }

    this.sort.emit({
      column: this.sortColumn,
      direction: this.sortDirection,
    });
  }

  onPageChange(page: number): void {
    if (page < 1 || page > this.totalPages) return;
    this.page.emit(page);
  }

  get totalPages(): number {
    return Math.ceil(this.totalItems / this.pageSize);
  }

  get pages(): number[] {
    const pageCount = this.totalPages;
    const maxPages = 5;
    const halfMaxPages = Math.floor(maxPages / 2);

    let startPage = Math.max(this.currentPage - halfMaxPages, 1);
    let endPage = startPage + maxPages - 1;

    if (endPage > pageCount) {
      endPage = pageCount;
      startPage = Math.max(endPage - maxPages + 1, 1);
    }

    return Array.from(
      { length: endPage - startPage + 1 },
      (_, i) => startPage + i
    );
  }

  onSelectAll(event: Event): void {
    const isChecked = (event.target as HTMLInputElement).checked;
    this.allSelected = isChecked;
    this.selectAll.emit(isChecked);
  }

  onSelectItem(event: Event, item: any): void {
    event.stopPropagation();
    this.selectItem.emit(item);
  }

  isSelected(item: any): boolean {
    return this.selectedItems.some(
      (selectedItem) => selectedItem.id === item.id
    );
  }

  onRowClick(item: any): void {
    this.rowClick.emit(item);
  }

  getValue(item: any, column: Column): any {
    const keys = column.key.split('.');
    let value = item;

    for (const key of keys) {
      if (value === null || value === undefined) return '';
      value = value[key];
    }

    return value;
  }

  getFormattedValue(item: any, column: Column): string {
    const value = this.getValue(item, column);

    if (column.format) {
      return column.format(value);
    }

    return value !== null && value !== undefined ? String(value) : '';
  }
}
