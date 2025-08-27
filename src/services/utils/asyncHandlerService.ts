import { injectable } from "tsyringe";
import { NextFunction, Request, Response } from "express-serve-static-core";
import { MongoServerError } from "mongodb";
import CustomError from "./errorService";
import ApiResponse from "./apiResponseService";

@injectable()
export default class AsyncHandler {
  constructor(private apiResponse: ApiResponse) {}

  private handleDuplicate(error: MongoServerError) {
    const errorMessage = error.errmsg;
    const collectionRegex = /collection: (\S+)/;
    const match = errorMessage.match(collectionRegex);

    if (match && match[1]) {
      if (match[1].split(".")[1] === "users") {
        return this.apiResponse.error("Invalid user credentials.");
      } else {
        const key = Object.keys(error.keyValue)[0];
        const value = error.keyValue[key];
        return this.apiResponse.error(
          `${value} already exists in ${match[1].split(".")[1]}`
        );
      }
    }

    return this.apiResponse.error(
      "Collection name not found in error message."
    );
  }

  private handleCustomError(error: CustomError) {
    const { validationError } = error.details;
    return this.apiResponse.error(error.message, validationError);
  }

  private handleOtherError(error: Error) {
    return this.apiResponse.error(error.message);
  }

  handler(
    fn: (req: Request, res: Response, next: NextFunction) => Promise<any>
  ) {
    return async (req: Request, res: Response, next: NextFunction) => {
      try {
        await fn(req, res, next);
      } catch (error) {
        // console.log(error);
        // Handle invalid ObjectId
        if ((error as Error).name === "CastError") {
          return this.apiResponse.error("Invalid ID format").send(res, 400);
        }

        // Handle Mongo duplicate key
        if (error instanceof MongoServerError && error.code === 11000) {
          return this.handleDuplicate(error).send(res, 409);
        }

        // Handle custom validation errors
        if (error instanceof CustomError) {
          const { statusCode } = error.details;
          return this.handleCustomError(error).send(res, statusCode);
        }

        // Generic JS Error
        if (error instanceof Error) {
          return this.handleOtherError(error).send(res, 500);
        }

        // Fallback
        return this.apiResponse.error("Internal server error.").send(res, 500);
      }
    };
  }
}
