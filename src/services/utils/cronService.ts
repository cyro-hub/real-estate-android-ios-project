import { injectable } from "tsyringe";
import cron from "node-cron";

@injectable()
export class CronService {
  constructor() {
    this.init();
  }

  private init() {
    // Example: run every day at midnight
    cron.schedule("0 0 * * *", async () => {
      console.log("Running daily cron job at midnight...");
    });

    // Example: run every hour
    cron.schedule("0 * * * *", async () => {
      // console.log("Running hourly cron job...");
    });
  }
}
