import { injectable } from "tsyringe";
import { Router } from "express";
import PropertyRouter from "./propertyRouter";
import AuthRouter from "./authRouter";
import TokenRouter from "./tokenRouter";
import RateLimiterService from "../services/utils/rateLimiterService";
import UserRouter from "./userRouter";
import AuthController from "../controllers/authController";
import PaymentRouter from "./paymentRouter";

@injectable()
export default class AppRouter {
  public appRouter: Router;

  constructor(
    private propertyRouter: PropertyRouter,
    private authRouter: AuthRouter,
    private tokenRouter: TokenRouter,
    private rateLimiter: RateLimiterService,
    private userRouter: UserRouter,
    private authController: AuthController,
    private paymentRouter: PaymentRouter
  ) {
    this.appRouter = Router();
    this.initializeRoutes();
  }

  private initializeRoutes() {
    this.appRouter.use(
      "/properties",
      this.rateLimiter.searchLimiter,
      this.propertyRouter.propertyRouter
    );
    this.appRouter.use(
      "/auth",
      this.rateLimiter.loginLimiter,
      this.authRouter.authRouter
    );
    this.appRouter.use(
      "/token",
      this.rateLimiter.loginLimiter,
      this.tokenRouter.tokenRouter
    );
    this.appRouter.use(
      "/users",
      this.rateLimiter.loginLimiter,
      this.authController.authenticate,
      this.userRouter.userRouter
    );
    this.appRouter.use("/payments", this.paymentRouter.paymentRouter);
  }
}
