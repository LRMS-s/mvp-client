import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

export function dateRangeValidator(startDateControlName: string, endDateControlName: string): ValidatorFn {
  return (formGroup: AbstractControl): ValidationErrors | null => {
    const startDateControl = formGroup.get(startDateControlName);
    const endDateControl = formGroup.get(endDateControlName);

    if (!startDateControl || !endDateControl) {
      return null;
    }

    const startDate = startDateControl.value;
    const endDate = endDateControl.value;

    if (!startDate || !endDate) {
      return null;
    }

    const start = new Date(startDate);
    const end = new Date(endDate);

    if (start > end) {
      return { dateRange: { startDate, endDate } };
    }

    return null;
  };
}

export function minDateValidator(minDate: Date | string | (() => Date)): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    if (!control.value) {
      return null;
    }

    const controlDate = new Date(control.value);

    if (isNaN(controlDate.getTime())) {
      return { invalidDate: { value: control.value } };
    }

    const compareDate = typeof minDate === 'function'
      ? minDate()
      : new Date(minDate);

    if (controlDate < compareDate) {
      return { minDate: { required: compareDate, actual: controlDate } };
    }

    return null;
  };
}

export function maxDateValidator(maxDate: Date | string | (() => Date)): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    if (!control.value) {
      return null;
    }

    const controlDate = new Date(control.value);

    if (isNaN(controlDate.getTime())) {
      return { invalidDate: { value: control.value } };
    }

    const compareDate = typeof maxDate === 'function'
      ? maxDate()
      : new Date(maxDate);

    if (controlDate > compareDate) {
      return { maxDate: { required: compareDate, actual: controlDate } };
    }

    return null;
  };
}
