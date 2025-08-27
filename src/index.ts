import "reflect-metadata";
import App from "./app";
import { container } from "tsyringe";
import dotenv from "dotenv";
import { CronService } from "./services/utils/cronService";

dotenv.config();

const cronService = container.resolve(CronService);

const app = container.resolve(App);

const PORT = process.env.PORT || 3000;

app.start(PORT);
