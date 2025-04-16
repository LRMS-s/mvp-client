import { Component, Input, Output, EventEmitter, ElementRef, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-file-upload',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './file-upload.component.html',
  styleUrl: './file-upload.component.scss'
})
export class FileUploadComponent {
  @ViewChild('fileInput') fileInput!: ElementRef<HTMLInputElement>;

  @Input() multiple = false;
  @Input() accept = '';
  @Input() maxSize = 5 * 1024 * 1024; // 5MB default
  @Input() label = 'Choose file';
  @Input() placeholder = 'No file chosen';
  @Input() showPreview = true;
  @Input() dragDrop = true;

  @Output() filesSelected = new EventEmitter<File[]>();
  @Output() fileError = new EventEmitter<string>();

  selectedFiles: File[] = [];
  isDragging = false;
  previews: string[] = [];

  onFileSelected(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (input.files) {
      this.processFiles(input.files);
    }
  }

  onDragOver(event: DragEvent): void {
    event.preventDefault();
    event.stopPropagation();
    this.isDragging = true;
  }

  onDragLeave(event: DragEvent): void {
    event.preventDefault();
    event.stopPropagation();
    this.isDragging = false;
  }

  onDrop(event: DragEvent): void {
    event.preventDefault();
    event.stopPropagation();
    this.isDragging = false;

    if (event.dataTransfer?.files) {
      this.processFiles(event.dataTransfer.files);
    }
  }

  triggerFileInput(): void {
    this.fileInput.nativeElement.click();
  }

  removeFile(index: number): void {
    this.selectedFiles.splice(index, 1);
    this.previews.splice(index, 1);
    this.filesSelected.emit(this.selectedFiles);
  }

  clearFiles(): void {
    this.selectedFiles = [];
    this.previews = [];
    this.fileInput.nativeElement.value = '';
    this.filesSelected.emit(this.selectedFiles);
  }

  private processFiles(files: FileList): void {
    const validFiles: File[] = [];

    for (let i = 0; i < files.length; i++) {
      const file = files[i];

      // Check file size
      if (file.size > this.maxSize) {
        this.fileError.emit(`File ${file.name} exceeds maximum size of ${this.formatSize(this.maxSize)}`);
        continue;
      }

      // Check file type if accept is specified
      if (this.accept && !this.isFileTypeValid(file)) {
        this.fileError.emit(`File ${file.name} is not a valid file type`);
        continue;
      }

      validFiles.push(file);

      // Generate preview for image files
      if (this.showPreview && file.type.startsWith('image/')) {
        this.createImagePreview(file);
      }
    }

    if (!this.multiple) {
      this.selectedFiles = validFiles.slice(0, 1);
      this.previews = this.previews.slice(0, 1);
    } else {
      this.selectedFiles = [...this.selectedFiles, ...validFiles];
    }

    this.filesSelected.emit(this.selectedFiles);
  }

  private isFileTypeValid(file: File): boolean {
    const acceptedTypes = this.accept.split(',').map(type => type.trim());
    const fileType = file.type;

    return acceptedTypes.some(type => {
      if (type.startsWith('.')) {
        // Check file extension
        return file.name.toLowerCase().endsWith(type.toLowerCase());
      } else if (type.endsWith('/*')) {
        // Check MIME type group (e.g., "image/*")
        const group = type.substring(0, type.length - 2);
        return fileType.startsWith(group);
      } else {
        // Check exact MIME type
        return fileType === type;
      }
    });
  }

  private createImagePreview(file: File): void {
    const reader = new FileReader();
    reader.onload = (e: any) => {
      this.previews.push(e.target.result);
    };
    reader.readAsDataURL(file);
  }

  private formatSize(bytes: number): string {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  }
}
