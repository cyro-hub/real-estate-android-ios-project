import { injectable } from "tsyringe";
import rateLimit from "express-rate-limit";
import RedisStore from "rate-limit-redis";
import { redisClient } from "../../config/redis";
import { Command } from "ioredis";

@injectable()
export class RedisService {
  constructor() {}

  private createStore() {
    return new RedisStore({
      sendCommand: (command: string, ...args: string[]) =>
        redisClient.sendCommand(new Command(command, args)) as Promise<any>, // 👈 cast fixes TS
    });
  }

  loginLimiter() {
    return rateLimit({
      store: this.createStore(),
      windowMs: 60 * 1000,
      max: 10,
      message: "Too many login attempts, please try again in a minute.",
    });
  }

  searchLimiter() {
    return rateLimit({
      store: this.createStore(),
      windowMs: 60 * 1000,
      max: 200,
      message: "Too many searches, please slow down.",
    });
  }

  heavyTaskLimiter() {
    return rateLimit({
      store: this.createStore(),
      windowMs: 60 * 1000,
      max: 20,
      message: "Too many requests for this resource, please wait a minute.",
    });
  }
}
