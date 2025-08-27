import mongoose from "mongoose";
import { injectable } from "tsyringe";
import CustomError from "./errorService";

@injectable()
export default class TransactionManager {
  public session: mongoose.ClientSession | null = null;

  async createAndStartTransaction() {
    try {
      this.session = await mongoose.startSession();
      await this.session.startTransaction();
    } catch (error) {
      throw new CustomError("Error starting transaction.", { statusCode: 500 });
    }
  }

  async abortTransaction() {
    if (this.session) {
      try {
        await this.session.abortTransaction();
        this.session = null;
      } catch (error) {
        throw new CustomError("Error aborting transaction.", {
          statusCode: 500,
        });
      }
    }
  }

  async commitTransaction() {
    if (this.session) {
      try {
        await this.session.commitTransaction();
        this.session = null;
      } catch (error) {
        throw new CustomError("Error committing transaction.", {
          statusCode: 500,
        });
      }
    }
  }

  async withTransaction<T>(callback: () => Promise<T>): Promise<T> {
    try {
      await this.createAndStartTransaction();
      const result = await callback();

      await this.commitTransaction();
      return result;
    } catch (error) {
      await this.abortTransaction();

      throw error;
    }
  }
}
