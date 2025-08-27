export interface ValidationErrorDetails {
  field: string;
  messages: string[];
}

export interface ErrorDetails {
  statusCode: number;
  validationError?: ValidationErrorDetails[];
}

export default class CustomError extends Error {
  details: ErrorDetails;

  constructor(message: string, details: ErrorDetails) {
    super(message);
    this.details = details;
    this.name = "CustomError";
  }
}
