import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-search-bar',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './search-bar.component.html',
  styleUrl: './search-bar.component.scss'
})
export class SearchBarComponent {
  @Input() placeholder = 'Search...';
  @Input() value = '';
  @Input() debounceTime = 300;
  @Input() minLength = 1;

  @Output() search = new EventEmitter<string>();
  @Output() valueChange = new EventEmitter<string>();
  @Output() clear = new EventEmitter<void>();

  private debounceTimer: any = null;

  onInput(event: Event): void {
    const value = (event.target as HTMLInputElement).value;
    this.valueChange.emit(value);

    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer);
    }

    if (value.length >= this.minLength) {
      this.debounceTimer = setTimeout(() => {
        this.search.emit(value);
      }, this.debounceTime);
    }
  }

  onClear(): void {
    this.value = '';
    this.valueChange.emit('');
    this.clear.emit();
  }
}
