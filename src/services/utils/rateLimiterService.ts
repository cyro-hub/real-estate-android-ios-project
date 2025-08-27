import { injectable } from "tsyringe";
import rateLimit from "express-rate-limit";
import { Request, Response } from "express";
import ApiResponse from "./apiResponseService";

@injectable()
export default class RateLimiterService {
  public readonly loginLimiter;
  public readonly searchLimiter;
  public readonly heavyTaskLimiter;

  constructor(private apiResponse: ApiResponse) {
    this.loginLimiter = rateLimit({
      windowMs: 60 * 1000,
      max: 10,
      standardHeaders: true,
      legacyHeaders: false,
      handler: (req: Request, res: Response) => {
        return this.apiResponse
          .error("Too many login attempts, please try again later.")
          .send(res, 429);
      },
    });

    this.searchLimiter = rateLimit({
      windowMs: 60 * 1000,
      max: 200,
      standardHeaders: true,
      legacyHeaders: false,
      handler: (req: Request, res: Response) => {
        return this.apiResponse
          .error("Too many searches, please slow down.")
          .send(res, 429);
      },
    });

    this.heavyTaskLimiter = rateLimit({
      windowMs: 60 * 1000,
      max: 20,
      standardHeaders: true,
      legacyHeaders: false,
      handler: (req: Request, res: Response) => {
        return this.apiResponse
          .error("Too many requests for this resource, please wait a minute.")
          .send(res, 429);
      },
    });
  }
}
