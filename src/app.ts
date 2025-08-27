import express, { Application } from "express";
import "reflect-metadata"; // Required for tsyringe
import { injectable } from "tsyringe";
import AppRouter from "./routes/indexRouter";
import mongoose from "mongoose";

@injectable()
class App {
  private app: Application;

  constructor(private appRouter: AppRouter) {
    this.app = express();
    this.initializeMiddleware();
    this.initializeRoutes();
    this.connectDB();
  }

  private initializeMiddleware() {
    this.app.use(express.json());
    this.app.use(express.urlencoded({ extended: true }));
  }

  private initializeRoutes() {
    // Use the appRouter's routes
    this.app.use("/api/v1", this.appRouter.appRouter);
  }

  private async connectDB() {
    try {
      const conn = await mongoose.connect(
        process.env.MONGODB_URI || "mongodb://localhost:27017/yourdbname"
      );
      console.log(`mongoDB Connected`);
    } catch (error) {
      console.error(`Error: ${(error as Error).message}`);
      process.exit(1); // Exit the process on connection failure
    }
  }

  public start(port: number | string = 3000) {
    this.app.listen(port, () => {
      console.log(`Server is running on port ${port}`);
    });
  }
}

export default App;
