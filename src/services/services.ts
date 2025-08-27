import { injectable } from "tsyringe";
import mongoose, { Model } from "mongoose";
import CustomError, { ValidationErrorDetails } from "./utils/errorService";
import { plainToInstance } from "class-transformer";
import { validate } from "class-validator";

@injectable()
export class Services<T> {
  protected message: string = "No message provided.";
  protected data: Partial<T> = {};
  protected model: Model<T>;

  constructor(model: Model<T>) {
    this.model = model;
  }

  createDoc = async (args: Partial<T>) => {
    const newDoc = new this.model(args);

    await newDoc.save();

    return newDoc;
  };

  getDoc = async (args: Partial<T>) => {
    const doc = await this.model.findOne(args);

    if (!doc) {
      throw new CustomError(`${this.getModelName()} not found.`, {
        statusCode: 404,
      });
    }

    return doc;
  };

  getDocs = async (args: Partial<T>) => {
    const docs = await this.model.find(args);

    return docs;
  };

  protected validateInput = async <U extends object>(
    dtoClass: new () => U,
    args: U
  ) => {
    // Convert plain object to class instance
    const createDto = plainToInstance(dtoClass, args);

    // Validate the DTO object
    const errors = await validate(createDto);

    // If there are validation errors
    if (errors.length > 0) {
      const validationErrors: ValidationErrorDetails[] = errors.map(
        (error) => ({
          field: error.property,
          messages: Object.values(error.constraints || {}),
        })
      );

      // Throw a custom error with validation details
      throw new CustomError("Validation failed.", {
        statusCode: 400,
        validationError: validationErrors,
      });
    }

    return;
  };

  validateObjectId = (id: string) => {
    if (!mongoose.Types.ObjectId.isValid(id)) {
      throw new CustomError(`Invalid ID.`, {
        statusCode: 400,
      });
    }
  };

  private getModelName(): string {
    return this.model.modelName; // Gets the model name automatically
  }
}
