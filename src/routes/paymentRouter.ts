import { Router } from "express";
import { injectable } from "tsyringe";
import PaymentController from "../controllers/paymentController";
// import AuthController from "../controllers/authController";
// import { authenticate } from "passport";

@injectable()
export default class PaymentRouter {
  public paymentRouter: Router;
  constructor(
    private paymentController: PaymentController // private authController: AuthController
  ) {
    this.paymentRouter = Router();
    this.initRoutes();
  }

  private initRoutes(): void {
    this.paymentRouter.post("/mtn", this.paymentController.requestToPayMtn);
  }
}
